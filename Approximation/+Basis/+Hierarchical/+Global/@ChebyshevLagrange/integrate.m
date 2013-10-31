function result = integrate(this, indexes, surpluses, offsets)
  [ indexCount, dimensionCount ] = size(indexes);

  weights = cell(indexCount, 1);
  for i = 1:indexCount
    if dimensionCount == 1
      weights{i} = this.weights{indexes(i)}(:);
    else
      weights{i} = prod(Utils.tensor(this.weights(indexes(i, :))), 2);
    end
  end

  if nargin == 2
    result = cellfun(@sum, weights);
    return;
  end

  result = 0;

  if size(surpluses, 2) == 1
    for i = 1:indexCount
      range = (offsets(i) + 1):(offsets(i) + prod(this.counts(indexes(i, :))));
      result = result + sum(surpluses(range) .* weights{i});
    end
  else
    for i = 1:indexCount
      range = (offsets(i) + 1):(offsets(i) + prod(this.counts(indexes(i, :))));
      result = result + sum(bsxfun(@times, surpluses(range, :), weights{i}), 1);
    end
  end
end
