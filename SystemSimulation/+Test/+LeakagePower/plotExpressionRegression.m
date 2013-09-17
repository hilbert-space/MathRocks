function plotExpressionRegression(varargin)
  T = sym('T');
  Leff = sym('Leff');

  C = sym(zeros(1, 4));
  for i = 1:4
    C(i) = sym(sprintf('C%d', i));
  end

  expression.formula = C(1) * T + C(2) * exp(C(3) + C(4) * Leff);
  expression.parameters = [ T, Leff ];
  expression.coefficients = C;

  assess('Regression.Expression', 'expression', expression, varargin{:});
end
