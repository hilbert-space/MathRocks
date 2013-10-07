function assessMoments(i, j)
  basis = Basis.Hat;

  if nargin > 0
    validate(basis, i, j);

    compare('Expectation', ...
      basis.deriveExpectation(i, j), ...
      basis.estimateExpectation(i, j));

    compare('Second raw moment', ...
      basis.deriveSecondRawMoment(i, j), ...
      basis.estimateSecondRawMoment(i, j));

    compare('Variance', ...
      basis.deriveVariance(i, j), ...
      basis.estimateVariance(i, j));
  else
    i = sym('i');
    j = sym('j');

    fprintf('Expectation:       %s\n', ...
      char(basis.deriveExpectation(i, j)));

    fprintf('Second raw moment: %s\n', ...
      char(basis.deriveSecondRawMoment(i, j)));

    fprintf('Variance:          %s\n', ...
      char(basis.deriveVariance(i, j)));
  end
end
