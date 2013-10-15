function result = estimateCovariance(basis, i1, j1, i2, j2)
  result = estimateCrossExpectation(basis, i1, j1, i2, j2) - ...
    estimateExpectation(basis, i1, j1) * estimateExpectation(basis, i2, j2);
end
