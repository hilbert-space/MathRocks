function [ nodes, offsets, counts, Li, Mi ] = computeNodes(this, indexes)
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
      nodes((offsets(i) + 1):(offsets(i) + counts(i)), K) = ...
        this.Yij{J(K)};
    otherwise
      nodes((offsets(i) + 1):(offsets(i) + counts(i)), K) = ...
        Utils.tensor(this.Yij(J(K)));
    end
  end

  if nargout < 3, return; end

  Li = reshape(this.Li(indexes), size(indexes));
  Mi = reshape(this.Mi(indexes), size(indexes));
end
