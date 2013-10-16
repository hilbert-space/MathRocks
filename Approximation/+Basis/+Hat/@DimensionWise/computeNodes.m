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

  nodeSets = cell(1, dimensionCount);
  for i = 1:indexCount
    J = I(i, :);

    count = prod(this.Ni(J));
    range = (offset + 1):(offset + count);
    offset = offset + count;

    [ nodeSets{:} ] = ndgrid(this.Yij{J});
    Yij(range, :) = cell2mat(cellfun(@(x) x(:), ...
      nodeSets, 'UniformOutput', false));
    mapping(range) = i;

    if nargout < 3, continue; end

    Li(i, :) = this.Li(J);
    Mi(i, :) = this.Mi(J);
  end

  assert(nodeCount == offset);
end
