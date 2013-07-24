function plotCustomExpression
  L = sym('L');
  T = sym('T');
  C = sym(zeros(1, 6));
  for i = 1:6
    C(i) = sym(sprintf('C%d', i));
  end
  F = C(1) + C(2) * T + C(3) * exp(C(4) + C(5) * L + C(6) * L^2);

  expression.L = L;
  expression.T = T;
  expression.C = C;
  expression.F = F;

  compare('CustomExpression', 'expression', expression);
end
