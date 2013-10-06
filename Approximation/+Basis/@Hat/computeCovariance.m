function result = computeCovariance(this, i1, j1, i2, j2)
  m1 = this.computeExpectation(i1, j1);
  m2 = this.computeExpectation(i2, j2);
  result = integral(@(Y) ...
    ((this.evaluate(i1, j1, Y.') - m1) .* ...
    (this.evaluate(i2, j2, Y.') - m2)), 0, 1);
end
