function assessMoments(i, j)
  basis = Basis.Local.NewtonCotesHat;

  if nargin > 0
    validate(basis, i, j);

    compare('Expectation', ...
      deriveExpectation(basis, i, j), ...
      estimateExpectation(basis, i, j));

    compare('Second raw moment', ...
      deriveSecondRawMoment(basis, i, j), ...
      estimateSecondRawMoment(basis, i, j));

    compare('Variance', ...
      deriveVariance(basis, i, j), ...
      estimateVariance(basis, i, j));
  else
    i = sym('i');
    j = sym('j');

    fprintf('Expectation:       %s\n', ...
      char(deriveExpectation(basis, i, j)));

    fprintf('Second raw moment: %s\n', ...
      char(deriveSecondRawMoment(basis, i, j)));

    fprintf('Variance:          %s\n', ...
      char(deriveVariance(basis, i, j)));
  end
end
