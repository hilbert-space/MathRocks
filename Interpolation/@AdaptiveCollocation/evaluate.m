function values = evaluate(this, newNodes)
  dimensionCount = this.dimensionCount;

  nodes = this.nodes;
  intervals = this.intervals;

  offset = this.offset;
  surpluses = this.surpluses;

  nodeCount = size(nodes, 1);

  newNodeCount = size(newNodes, 1);
  values = zeros(newNodeCount, 1);

  delta = zeros(nodeCount, dimensionCount);

  for i = 1:newNodeCount
    for j = 1:dimensionCount
      delta(:, j) = abs(nodes(:, j) - newNodes(i, j));
    end
    I = find(all(delta < 1.0 ./ intervals, 2));
    bases = prod(1.0 - intervals(I, :) .* delta(I, :), 2);
    values(i) = offset + sum(surpluses(I) .* bases);
  end
end
