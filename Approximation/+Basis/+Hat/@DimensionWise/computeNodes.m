function [ Yij, mapping, Li, Mi ] = computeNodes(this, I)
  [ indexCount, dimensionCount ] = size(I);

  indexNodeCount = prod(reshape(this.Ni(I), size(I)), 2);
  nodeCount = sum(indexNodeCount);

  Yij = 0.5 * ones(nodeCount, dimensionCount);
  mapping = zeros(nodeCount, 1, 'uint32');

  if nargout > 2
    Li = zeros(indexCount, dimensionCount);
    Mi = zeros(indexCount, dimensionCount, 'uint32');
  end

  offset = 0;
  for i = 1:indexCount
    J = I(i, :);

    range = (offset + 1):(offset + indexNodeCount(i));
    offset = offset + indexNodeCount(i);

    K = find(J > 1);
    switch numel(K)
    case 0
    case 1
      Yij(range, K) = this.Yij{J(K)};
    otherwise
      Yij(range, K) = Utils.tensor(this.Yij(J(K)));
    end

    mapping(range) = i;

    if nargout < 3, continue; end

    Li(i, :) = this.Li(J);
    Mi(i, :) = this.Mi(J);
  end

  assert(nodeCount == offset);
end
