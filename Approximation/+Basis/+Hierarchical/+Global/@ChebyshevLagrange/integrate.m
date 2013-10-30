function result = integrate(this, indexes, surpluses, offsets, range)
  if ~exist('range', 'var'), range = 1:size(indexes, 1); end

  dimensionCount = size(indexes, 2);
  outputCount = size(surpluses, 2);

  result = 0;

  for i = range
    range = (offsets(i) + 1):(offsets(i) + prod(this.counts(indexes(i, :))));
    if dimensionCount == 1
      weights = this.weights{indexes(i)}(:);
    else
      weights = prod(Utils.tensor(this.weights(indexes(i ,:))), 2);
    end
    if outputCount == 1
      result = result + sum(surpluses(range) .* weights);
    else
      result = result + sum(bsxfun(@times, surpluses(range, :), weights), 1);
    end
  end
end
