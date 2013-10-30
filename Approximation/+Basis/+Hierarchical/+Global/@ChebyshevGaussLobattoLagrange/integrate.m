function result = integrate(this, indexes, surpluses)
  [ indexCount, dimensionCount ] = size(indexes);
  outputCount = size(surpluses, 2);

  counts = prod(reshape(this.counts(indexes), indexCount, []), 2);
  offsets = cumsum([ 0; counts(1:(end - 1)) ]);

  result = 0;
  for i = 1:indexCount
    range = (offsets(i) + 1):(offsets(i) + counts(i));
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
