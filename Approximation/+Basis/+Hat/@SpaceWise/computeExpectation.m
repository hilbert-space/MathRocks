function result = computeExpectation(this, I, ~, C)
  result = sum(bsxfun(@times, C, this.computeBasisExpectation(I)));
end
