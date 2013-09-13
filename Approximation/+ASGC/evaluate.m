function values = evaluate(output, newNodes)
  zeros = @uninit;

  planeNewNodes = newNodes(:);
  assert(all(planeNewNodes >= 0) && all(planeNewNodes <= 1));

  inputCount = output.inputCount;
  outputCount = output.outputCount;

  nodes = output.nodes;
  levelIndex = output.levelIndex;
  surpluses = output.surpluses;

  nodeCount = size(nodes, 1);

  newNodeCount = size(newNodes, 1);
  values = zeros(newNodeCount, outputCount);

  delta = zeros(nodeCount, inputCount);

  intervals = 2.^(double(levelIndex) - 1);
  inverseIntervals = 1.0 ./ intervals;

  for i = 1:newNodeCount
    for j = 1:inputCount
      delta(:, j) = abs(nodes(:, j) - newNodes(i, j));
    end
    I = find(all(delta < inverseIntervals, 2));

    bases = 1.0 - intervals(I, :) .* delta(I, :);
    bases(levelIndex(I, :) == 1) = 1;
    bases = prod(bases, 2);

    values(i, :) = sum(bsxfun(@times, surpluses(I, :), bases), 1);
  end
end
