function [ nodes, offsets, counts ] = computeNodes(this, indexes)
  [ indexCount, dimensionCount ] = size(indexes);

  counts = prod(reshape(this.Ni(indexes), size(indexes)), 2);
  offsets = cumsum([ 0; counts(1:(end - 1)) ]);

  nodes = 0.5 * ones(sum(counts), dimensionCount);

  for i = 1:indexCount
    J = indexes(i, :);
    K = find(J > 1);
    switch numel(K)
    case 0
    case 1
      range = (offsets(i) + 1):(offsets(i) + counts(i));
      nodes(range, K) = this.Yij{J(K)};
    otherwise
      range = (offsets(i) + 1):(offsets(i) + counts(i));
      nodes(range, K) = Utils.tensor(this.Yij(J(K)));
    end
  end
end
