function output = construct(this, Ldata, Tdata, Idata, options)
  order = options.order;
  scale = options.scale;

  maxOrder = max(order);

  assert(numel(order) == 2);
  assert(size(scale, 1) == 2 && size(scale, 2) == maxOrder + 1);

  [ fitobject, expectation, deviation ] = ...
    performPolynomialFit(Ldata, Tdata, log(Idata), order);

  values = coeffvalues(fitobject);
  names = coeffnames(fitobject);

  output.Lorder = order(1);
  output.Torder = order(2);
  output.expectation = expectation;
  output.deviation = deviation;
  output.coefficients = zeros(order(1) + 1, order(2) + 1);
  output.scale = zeros(order(1) + 1, order(2) + 1);

  Lsym = sympoly('L');
  Tsym = sympoly('T');

  Lnorm = (Lsym - expectation(1)) / deviation(1);
  Tnorm = (Tsym - expectation(2)) / deviation(2);

  logI = sympoly(0);

  for i = 1:numel(names)
    attributes = regexp(names{i}, '^p(\d)(\d)$', 'tokens');

    Lorder = str2num(attributes{1}{1});
    Torder = str2num(attributes{1}{2});

    alpha = scale(1, Lorder + 1) * scale(2, Torder + 1);

    output.coefficients(Lorder + 1, Torder + 1) = values(i);
    output.scale(Lorder + 1, Torder + 1) = alpha;

    logI = logI + alpha * values(i) * Lnorm^Lorder * Tnorm^Torder;
  end

  if options.has('dynamicPower')
    Pmean = this.PleakPdyn * mean(options.dynamicPower(:));
    P0 = exp(double(subs(subs(logI, Lsym, this.Lnom), Tsym, this.Tref)));
    output.powerScale = Pmean / P0;
  else
    output.powerScale = 1;
  end

  [ arguments, body ] = Utils.toFunctionString(logI, Lsym, Tsym);
  string = sprintf('@(%s)%s*exp(%s)', ...
    arguments, num2string(output.powerScale, 'longg'), body);

  output.evaluate = str2func(string);
end

function [ fitobject, expectation, deviation ] = ...
  performPolynomialFit(L, T, I, order)

  [ X, Y, Z ] = prepareSurfaceData(L, T, I);
  X = [ X, Y ];
  Y = Z;

  type = fittype(sprintf('poly%d%d', order(1), order(2)));

  count = order(1) * order(2) + 1;

  options = fitoptions(type);
  options.Normalize = 'off';
  options.Lower = -Inf(1, count);
  options.Upper =  Inf(1, count);

  [ X, expectation, deviation ] = curvefit.normalize(X);
  fitobject = fit(X, Y, type, options);
end
