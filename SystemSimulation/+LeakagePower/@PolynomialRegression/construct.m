function output = construct(this, Lgrid, Tgrid, Igrid, options)
  order = options.order;

  maxOrder = max(order);

  scale = options.get('scale', ones(2, maxOrder + 1));

  assert(numel(order) == 2);
  assert(size(scale, 1) == 2 && size(scale, 2) == maxOrder + 1);

  [ fitobject, expectation, deviation ] = ...
    performPolynomialFit(Lgrid(:), Tgrid(:), log(Igrid(:)), order);

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
  performPolynomialFit(X, Y, Z, order)

  type = fittype(sprintf('poly%d%d', order(1), order(2)));

  count = order(1) * order(2) + 1;

  options = fitoptions(type);
  options.Normalize = 'off';
  options.Lower = -Inf(1, count);
  options.Upper =  Inf(1, count);

  [ XY, expectation, deviation ] = curvefit.normalize([ X, Y ]);
  fitobject = fit(XY, Z, type, options);
end
