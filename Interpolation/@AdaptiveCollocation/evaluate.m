function values = evaluate(this, newNodes)
  zeros = @uninit;

  assert(all(all(newNodes >= 0)) && all(all(newNodes <= 1)));

  inputDimension = this.inputDimension;
  outputDimension = this.outputDimension;

  nodes = this.nodes;
  levelIndex = this.levelIndex;
  surpluses = this.surpluses;

  nodeCount = size(nodes, 1);

  newNodeCount = size(newNodes, 1);
  values = zeros(newNodeCount, outputDimension);

  delta = zeros(nodeCount, inputDimension);

  intervals = 2.^(double(levelIndex) - 1);
  inverseIntervals = 1.0 ./ intervals;

  for i = 1:newNodeCount
    for j = 1:inputDimension
      delta(:, j) = abs(nodes(:, j) - newNodes(i, j));
    end
    I = find(all(delta < inverseIntervals, 2));

    bases = 1.0 - intervals(I, :) .* delta(I, :);
    bases(levelIndex(I) == 1) = 1;
    bases = prod(bases, 2);

    values(i, :) = sum(bsxfun(@times, surpluses(I, :), bases), 1);
  end
end
