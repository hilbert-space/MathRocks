function [ output, arguments, body ] = construct(this, Z, XY, options)
  assert(length(XY) == 2);

  terms = options.terms;
  [ termCount, variableCount ] = size(terms);
  assert(variableCount == 2);

  [ C, E, S ] = perform(XY{1}, XY{2}, Z, terms);

  Xsym = sympoly('X');
  Ysym = sympoly('Y');

  Xnorm = (Xsym - E(1)) / S(1);
  Ynorm = (Ysym - E(2)) / S(2);

  Zsym = sympoly(0);
  for i = 1:termCount
    Zsym = Zsym + C(i) * Xnorm^terms(i, 1) * Ynorm^terms(i, 2);
  end

  [ arguments, body ] = Utils.toFunctionString(Zsym, Xsym, Ysym);
  string = sprintf('@(%s)%s', arguments, body);

  output.evaluate = str2func(string);
end

function [ C, E, S ] = perform(X, Y, Z, terms)
  X = X(:);
  Y = Y(:);
  Z = Z(:);

  E = [ mean(X), mean(Y) ];
  S = [ std(X), std(Y) ];

  X = (X - E(1)) / S(1);
  Y = (Y - E(2)) / S(2);

  dataCount = length(X);
  termCount = size(terms, 1);

  T = zeros(dataCount, termCount);
  for i = 1:termCount
    T(:, i) = X.^terms(i, 1) .* Y.^terms(i, 2);
  end

  C = (T' * T) \ (T' * Z);
end
