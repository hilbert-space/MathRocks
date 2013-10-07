function result = deriveCovariance(this, i1, j1, i2, j2)
  result = this.deriveCrossExpectation(i1, j1, i2, j2) - ...
    this.deriveExpectation(i1, j1) * this.deriveExpectation(i2, j2);
end
