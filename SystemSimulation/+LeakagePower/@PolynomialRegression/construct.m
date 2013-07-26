function [ output, arguments, body ] = construct(this, V, T, I, options)
  terms = options.terms;
  [ termCount, variableCount ] = size(terms);
  assert(variableCount == 2);

  [ C, E, S ] = perform(V, T, I, terms);

  Lsym = sympoly('L');
  Tsym = sympoly('T');

  Lnorm = (Lsym - E(1)) / S(1);
  Tnorm = (Tsym - E(2)) / S(2);

  Isym = sympoly(0);
  for i = 1:termCount
    Isym = Isym + C(i) * Lnorm^terms(i, 1) * Tnorm^terms(i, 2);
  end

  [ arguments, body ] = Utils.toFunctionString(Isym, Lsym, Tsym);
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
