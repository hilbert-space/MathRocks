function [ output, arguments, body ] = regress(~, Z, XY, termPowers)
  assert(length(XY) == 2 && length(termPowers) == 2);

  termCount = length(termPowers{1});
  assert(length(termPowers{2}) == termCount);

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
    T(:, i) = X.^termPowers{1}(i) .* Y.^termPowers{2}(i);
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
    Zs = Zs + C(i) * Xn^termPowers{1}(i) * Yn^termPowers{2}(i);
  end

  [ arguments, body ] = Utils.toFunctionString(Zs, Xs, Ys);
  string = sprintf('@(%s)%s', arguments, body);

  output.evaluate = str2func(string);
end
