function result = computeCovariance(i1, j1, i2, j2)
  m1 = computeExpectation(i1, j1);
  m2 = computeExpectation(i2, j2);
  result = integral(@(y) ...
    (base(y, i1, j1) - m1) .* (base(y, i2, j2) - m2), 0, 1);
end
