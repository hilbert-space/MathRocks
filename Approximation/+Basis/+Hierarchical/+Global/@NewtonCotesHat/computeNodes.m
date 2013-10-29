function [ Yij, offsets, counts, Li, Mi ] = computeNodes(this, I)
  [ indexCount, dimensionCount ] = size(I);

  counts = prod(reshape(this.Ni(I), size(I)), 2);
  offsets = cumsum([ 0; counts(1:(end - 1)) ]);

  Yij = 0.5 * ones(sum(counts), dimensionCount);

  for i = 1:indexCount
    J = I(i, :);
    K = find(J > 1);
    switch numel(K)
    case 0
    case 1
      Yij((offsets(i) + 1):(offsets(i) + counts(i)), K) = this.Yij{J(K)};
    otherwise
      Yij((offsets(i) + 1):(offsets(i) + counts(i)), K) = Utils.tensor(this.Yij(J(K)));
    end
  end

  if nargout < 3, return; end

  Li = reshape(this.Li(I), size(I));
  Mi = reshape(this.Mi(I), size(I));
end
