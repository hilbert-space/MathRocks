function [ Yij, mapping, Li, Mi ] = computeNodes(this, I)
  [ indexCount, inputCount ] = size(I);

  nodeCount = sum(this.Ni(I(:)));

  Yij = zeros(nodeCount, inputCount);
  mapping = zeros(nodeCount, 1, 'uint32');

  if nargout > 2
    Li = zeros(nodeCount, inputCount);
    Mi = zeros(nodeCount, inputCount, 'uint32');
  end

  offset = 0;

  nodeSets = cell(1, inputCount);
  for i = 1:indexCount
    J = I(i, :);

    count = sum(this.Ni(J));
    range = (offset + 1):(offset + count);
    offset = offset + count;

    [ nodeSets{:} ] = ndgrid(this.Yij{J});
    Yij(range, :) = cell2mat(cellfun(@(x) x(:), ...
      nodeSets, 'UniformOutput', false));
    mapping(range) = i;

    if nargout < 3, continue; end

    Li(range, :) = this.Li(J);
    Mi(range, :) = this.Mi(J);
  end

  assert(nodeCount == offset);
end
