function [ Yij, offsets, counts, Ji, Mi ] = computeNodes(this, I)
  [ indexCount, dimensionCount ] = size(I);

  counts = prod(reshape(this.Ni(I), size(I)), 2);
  offsets = cumsum([ 0; counts(1:(end - 1)) ]);

  Yij = 0.5 * ones(sum(counts), dimensionCount);
  Ji = ones(size(Yij), 'uint32');

  for i = 1:indexCount
    J = I(i, :);
    K = find(J > 1);
    switch numel(K)
    case 0
    case 1
      range = (offsets(i) + 1):(offsets(i) + counts(i));
      Yij(range, K) = this.Yij{J(K)};
      Ji(range, K) = this.Ji{J(K)};
    otherwise
      range = (offsets(i) + 1):(offsets(i) + counts(i));
      Yij(range, K) = Utils.tensor(this.Yij(J(K)));
      Ji(range, K) = Utils.tensor(this.Ji(J(K)));
    end
  end

  Mi = reshape(this.Mi(I), size(I));
end
