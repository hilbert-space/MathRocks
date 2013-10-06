function result = computeExpectation(this, i, j)
  result = integral(@(Y) this.evaluate(i, j, Y.'), 0, 1);
end
