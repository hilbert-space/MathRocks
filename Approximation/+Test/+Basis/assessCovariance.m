function assessCovariance(i1, j1, i2, j2)
  basis = Basis.Hat;

  validate(basis, i1, j1);
  validate(basis, i2, j2);

  compare('Covariance', ...
    basis.deriveCovariance(i1, j1, i2, j2), ...
    basis.computeCovariance(i1, j1, i2, j2));
end
