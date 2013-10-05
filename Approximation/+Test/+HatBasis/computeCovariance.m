function computeCovariance(i1, j1, i2, j2)
  validate(i1, j1);
  validate(i2, j2);

  C = computeCovariance(i1, j1, i2, j2);
  fprintf('Covariance: %10.8f\n', C);
end
