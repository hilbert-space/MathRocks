function [ output, arguments, body ] = regress(this, Z, XY, options)
  terms = options.terms;

  [ termCount, parameterCount ] = size(terms);

  assert(length(XY) == 2 && parameterCount == 2);

  X = XY{1}(:);
  Y = XY{2}(:);
  Z = Z(:);

  dataCount = length(X);

  %
  % Normalization
  %
  E = [ mean(X), mean(Y) ];
  S = [  std(X),  std(Y) ];

  X = (X - E(1)) / S(1);
  Y = (Y - E(2)) / S(2);

  %
  % Regression
  %
  T = zeros(dataCount, termCount);
  for i = 1:termCount
    T(:, i) = X.^terms(i, 1) .* Y.^terms(i, 2);
  end

  C = (T' * T) \ (T' * Z);

  %
  % Post-processing
  %
  Xs = sympoly('X');
  Ys = sympoly('Y');

  Xn = (Xs - E(1)) / S(1);
  Yn = (Ys - E(2)) / S(2);

  Zs = sympoly(0);
  for i = 1:termCount
    Zs = Zs + C(i) * Xn^terms(i, 1) * Yn^terms(i, 2);
  end

  [ arguments, body ] = Utils.toFunctionString(Zs, Xs, Ys);
  string = sprintf('@(%s)%s', arguments, body);

  output.evaluate = str2func(string);
end
