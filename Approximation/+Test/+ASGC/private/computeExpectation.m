function result = computeExpectation(i, j)
  result = integral(@(x) base(x, i, j), 0, 1);
end
