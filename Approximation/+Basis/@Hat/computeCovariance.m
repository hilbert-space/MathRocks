function result = computeCovariance(this, i1, j1, i2, j2)
  m1 = this.computeExpectation(i1, j1);
  m2 = this.computeExpectation(i2, j2);
  result = integral(@(y) ...
    (this.evaluate(y, i1, j1) - m1) .* (this.evaluate(y, i2, j2) - m2), 0, 1);
end
