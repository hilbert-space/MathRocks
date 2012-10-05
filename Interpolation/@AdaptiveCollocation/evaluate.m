function values = evaluate(this, newNodes)
  dimensionCount = this.dimensionCount;

  nodes = this.nodes;
  levelIndex = this.levelIndex;
  surpluses = this.surpluses;

  intervals = 2.^(double(levelIndex) - 1);

  nodeCount = size(nodes, 1);

  newNodeCount = size(newNodes, 1);
  values = zeros(newNodeCount, 1);

  delta = zeros(nodeCount, dimensionCount);

  for i = 1:newNodeCount
    for j = 1:dimensionCount
      delta(:, j) = abs(nodes(:, j) - newNodes(i, j));
    end
    I = find(all(delta < 1.0 ./ intervals, 2));

    bases = 1.0 - intervals(I, :) .* delta(I, :);
    bases(find(levelIndex(I) == 1)) = 1;
    bases = prod(bases, 2);

    values(i) = sum(surpluses(I) .* bases);
  end
end
