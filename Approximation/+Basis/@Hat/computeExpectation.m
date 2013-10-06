function result = computeExpectation(this, i, j)
  result = integral(@(Y) this.evaluate(Y.', i, j), 0, 1);
end
