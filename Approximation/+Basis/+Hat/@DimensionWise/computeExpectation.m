function result = computeExpectation(this, indexes, surpluses, offsets, counts)
  indexCount = size(indexes, 1);

  expectation = this.computeBasisExpectation(indexes);

  result = 0;
  for i = 1:indexCount
    range = (offsets(i) + 1):(offsets(i) + counts(i));
    result = result + sum(surpluses(range, :) * expectation(i), 1);
  end
end
