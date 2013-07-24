function [ output, arguments, body ] = construct( ...
  this, Lgrid, Tgrid, Igrid, options)

  terms = options.terms;
  [ termCount, variableCount ] = size(terms);
  assert(variableCount == 2);

  [ coefficients, expectation, deviation ] = ...
    perform(Lgrid, Tgrid, Igrid, terms);

  Lsym = sympoly('L');
  Tsym = sympoly('T');

  Lnorm = (Lsym - expectation(1)) / deviation(1);
  Tnorm = (Tsym - expectation(2)) / deviation(2);

  I = sympoly(0);
  for i = 1:termCount
    I = I + coefficients(i) * Lnorm^terms(i, 1) * Tnorm^terms(i, 2);
  end

  [ arguments, body ] = Utils.toFunctionString(I, Lsym, Tsym);
  string = sprintf('@(%s)%s', arguments, body);

  output.evaluate = str2func(string);
end

function [ coefficients, expectation, deviation ] = perform(X, Y, Z, terms)
  X = X(:);
  Y = Y(:);
  Z = Z(:);

  expectation = [ mean(X), mean(Y) ];
  deviation   = [  std(X),  std(Y) ];

  X = (X - expectation(1)) / deviation(1);
  Y = (Y - expectation(2)) / deviation(2);

  dataCount = length(X);
  termCount = size(terms, 1);

  T = zeros(dataCount, termCount);
  for i = 1:termCount
    T(:, i) = X.^terms(i, 1) .* Y.^terms(i, 2);
  end

  coefficients = (T' * T) \ (T' * Z);
end
