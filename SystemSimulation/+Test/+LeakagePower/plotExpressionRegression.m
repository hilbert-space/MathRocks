function plotExpressionRegression(varargin)
  X = sym('X');
  Y = sym('Y');
  C = sym(zeros(1, 4));
  for i = 1:4
    C(i) = sym(sprintf('C%d', i));
  end
  F = C(1) * X + C(2) * exp(C(3) + C(4) * Y);

  expression.formula = F;
  expression.parameters = [ X, Y ];
  expression.coefficients = C;

  assess('Regression.Expression', 'expression', expression, varargin{:});
end
