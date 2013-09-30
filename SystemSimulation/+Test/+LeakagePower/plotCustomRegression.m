function plotCustomRegression(varargin)
  T = sym('T');
  L = sym('L');

  C = sym(zeros(1, 4));
  for i = 1:4
    C(i) = sym(sprintf('C%d', i));
  end

  expression.formula = C(1) * T + C(2) * exp(C(3) + C(4) * L);
  expression.parameters = [ T, L ];
  expression.coefficients = C;

  assess('leakageOptions', Options( ...
    'approximation', 'Regression.Custom', ...
    'expression', expression, ...
    'rangeConstraints', Options( ...
      'T', Utils.toKelvin([ 50, 100 ]), ...
      'L', 50e-9 + 0.05 * 22.5e-9 * [ -1, 1 ])), ...
    varargin{:});
end
