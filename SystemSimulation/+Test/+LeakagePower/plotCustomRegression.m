function plotCustomRegression
  V = sym('V');
  T = sym('T');
  C = sym(zeros(1, 4));
  for i = 1:4
    C(i) = sym(sprintf('C%d', i));
  end
  F = C(1) * T + C(2) * exp(C(3) + C(4) * V);

  expression.V = V;
  expression.T = T;
  expression.C = C;
  expression.F = F;

  compare('CustomRegression', 'expression', expression);
end
