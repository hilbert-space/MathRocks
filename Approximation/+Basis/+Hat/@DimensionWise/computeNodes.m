function [ Yij, offsets, counts, Li, Mi ] = computeNodes(this, I)
  [ indexCount, dimensionCount ] = size(I);

  counts = prod(reshape(this.Ni(I), size(I)), 2);
  offsets = cumsum([ 0; counts(1:(end - 1)) ]);

  Yij = 0.5 * ones(sum(counts), dimensionCount);

  if nargout > 2
    Li = zeros(indexCount, dimensionCount);
    Mi = zeros(indexCount, dimensionCount, 'uint32');
  end

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

    if nargout < 3, continue; end

    Li(i, :) = this.Li(J);
    Mi(i, :) = this.Mi(J);
  end
end
