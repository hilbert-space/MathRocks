function assessCrossExpectation(i1, j1, i2, j2)
  basis = Basis.Local.NewtonCotesHat;

  validate(basis, i1, j1);
  validate(basis, i2, j2);

  compare('Cross expectation', ...
    deriveCrossExpectation(basis, i1, j1, i2, j2), ...
    estimateCrossExpectation(basis, i1, j1, i2, j2));
end
