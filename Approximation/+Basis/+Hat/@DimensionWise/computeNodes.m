function [ Yij, mapping, Li, Mi ] = computeNodes(this, I)
  [ indexCount, dimensionCount ] = size(I);

  nodeCount = sum(prod(reshape(this.Ni(I), size(I)), 2));

  Yij = zeros(nodeCount, dimensionCount);
  mapping = zeros(nodeCount, 1, 'uint32');

  if nargout > 2
    Li = zeros(indexCount, dimensionCount);
    Mi = zeros(indexCount, dimensionCount, 'uint32');
  end

  offset = 0;
  for i = 1:indexCount
    J = I(i, :);

    range = (offset + 1):(offset + prod(this.Ni(J)));
    offset = range(end);

    Yij(range, :) = Utils.tensor(this.Yij(J));
    mapping(range) = i;

    if nargout < 3, continue; end

    Li(i, :) = this.Li(J);
    Mi(i, :) = this.Mi(J);
  end

  assert(nodeCount == offset);
end
