function result = computeExpectation(this, i, j)
  result = integral(@(x) this.evaluate(x, i, j), 0, 1);
end
