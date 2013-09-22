function plotCustomRegression(varargin)
  T = sym('T');
  Leff = sym('Leff');

  C = sym(zeros(1, 4));
  for i = 1:4
    C(i) = sym(sprintf('C%d', i));
  end

  expression.formula = C(1) * T + C(2) * exp(C(3) + C(4) * Leff);
  expression.parameters = [ T, Leff ];
  expression.coefficients = C;

  assess('leakageOptions', Options( ...
    'approximation', 'Regression.Custom', ...
    'expression', expression, ...
    'rangeConstraints', Options( ...
      'T', Utils.toKelvin([ 50, 100 ]), ...
      'Leff', 45e-9 + 0.05 * 45e-9 * [ -1, 1 ])), ...
    varargin{:});
end
