function [ output, arguments, body ] = construct( ...
  this, Lgrid, Tgrid, Igrid, options)

  order = options.order;
  assert(numel(order) == 2);

  [ fitobject, expectation, deviation ] = ...
    performPolynomialFit(Lgrid(:), Tgrid(:), Igrid(:), order);

  values = coeffvalues(fitobject);
  names = coeffnames(fitobject);

  output.Lorder = order(1);
  output.Torder = order(2);
  output.expectation = expectation;
  output.deviation = deviation;
  output.coefficients = zeros(order(1) + 1, order(2) + 1);

  Lsym = sympoly('L');
  Tsym = sympoly('T');

  Lnorm = (Lsym - expectation(1)) / deviation(1);
  Tnorm = (Tsym - expectation(2)) / deviation(2);

  I = sympoly(0);

  for i = 1:numel(names)
    attributes = regexp(names{i}, '^p(\d)(\d)$', 'tokens');

    Lorder = str2num(attributes{1}{1});
    Torder = str2num(attributes{1}{2});

    output.coefficients(Lorder + 1, Torder + 1) = values(i);

    I = I + values(i) * Lnorm^Lorder * Tnorm^Torder;
  end

  [ arguments, body ] = Utils.toFunctionString(I, Lsym, Tsym);
  string = sprintf('@(%s)%s', arguments, body);

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
