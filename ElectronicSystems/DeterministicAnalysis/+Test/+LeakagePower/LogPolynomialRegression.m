function LogPolynomialRegression(varargin)
  setup;
  assess('processParameters', { 'Leff' }, 'leakageOptions', Options( ...
    'method', 'Regression', 'basis', 'LogPolynomial', ...
    'termPowers', Options( ...
      'T', [0, 0, 1, 1, 0, 1], ...
      'Leff', [0, 1, 0, 1, 2, 2])), ...
    varargin{:});
end
