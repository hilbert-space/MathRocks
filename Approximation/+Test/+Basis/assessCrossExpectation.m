function assessCrossExpectation(i1, j1, i2, j2)
  basis = Basis.Hat;

  validate(basis, i1, j1);
  validate(basis, i2, j2);

  compare('Cross expectation', ...
    basis.deriveCrossExpectation(i1, j1, i2, j2), ...
    basis.estimateCrossExpectation(i1, j1, i2, j2));
end
