function result = computeExpectation(this, levels, surpluses)
  result = sum(bsxfun(@times, surpluses, ...
    this.computeBasisExpectation(levels)));
end
