function result = computeExpectation(~, I, surpluses, offsets, counts)
  expectation = 2.^(1 - double(I));
  expectation(I == 1) = 1;
  expectation(I == 2) = 1 / 4;
  expectation = prod(expectation, 2);

  result = 0;
  for i = 1:size(I, 1)
    range = (offsets(i) + 1):(offsets(i) + counts(i));
    result = result + sum(surpluses(range, :) * expectation(i), 1);
  end
end
