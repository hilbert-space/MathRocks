function [ evaluator, Ldata, Tdata, Idata ] = construct(this, options)
  filename = options.filename;
  order = options.order;
  scale = options.scale;

  maxOrder = max(order);

  assert(numel(order) == 2);
  assert(size(scale, 1) == 2 && size(scale, 2) == maxOrder + 1);

  data = dlmread(filename, '\t', 1, 0);

  Ldata = data(:, 1);
  Tdata = Utils.toKelvin(data(:, 2));
  Idata = data(:, 3);

  [ fitresult, ~, expectation, deviation ] = ...
    performPolynomialFit(Ldata, Tdata, log(Idata), order);

  values = coeffvalues(fitresult);
  names = coeffnames(fitresult);

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

    logI = logI + alpha * values(i) * Lnorm^Lorder * Tnorm^Torder;
  end

  [ arguments, body ] = Utils.toFunctionString(logI, Lsym, Tsym);
  evaluator =  str2func([ '@(', arguments, ')exp(', body, ')' ]);
end
