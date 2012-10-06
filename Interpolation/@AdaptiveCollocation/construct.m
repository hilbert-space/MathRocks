function construct(this, f, options)
  zeros = @uninit;

  inputDimension = options.inputDimension;
  outputDimension = options.get('outputDimension', 1);

  tolerance = options.get('tolerance', 1e-3);
  minLevel = options.get('minLevel', 2);
  maxLevel = options.get('maxLevel', 10);

  bufferIncreaseFactor = 1;
  bufferSize = 200 * inputDimension;
  stepBufferSize = 100 * 2 * inputDimension;

  %
  % Allocate some memory.
  %
  levelIndex = zeros(bufferSize, inputDimension, 'uint8');
  nodes      = zeros(bufferSize, inputDimension);
  values     = zeros(bufferSize, outputDimension);
  surpluses  = zeros(bufferSize, outputDimension);
  surpluses2 = zeros(bufferSize, outputDimension);

  oldOrderIndex = zeros(stepBufferSize, inputDimension, 'uint32');
  newLevelIndex = zeros(stepBufferSize, inputDimension, 'uint8');
  newOrderIndex = zeros(stepBufferSize, inputDimension, 'uint32');
  newNodes      = zeros(stepBufferSize, inputDimension);

  %
  % The first two levels.
  %
  nodeCount = 1 + 2 * inputDimension;

  levelIndex(1:nodeCount, :) = 1;
  nodes     (1:nodeCount, :) = 0.5;

  for i = 1:inputDimension
    %
    % The left and right most nodes.
    %
    k = 1 + 2 * (i - 1) + 1;
    levelIndex(k:(k + 1), i) = 2;
    nodes     (k:(k + 1), i) = [ 0.0; 1.0 ];
  end

  %
  % Evaluate the function on the first two levels.
  %
  values(1:nodeCount, :) = f(nodes(1:nodeCount, :));
  surpluses (1, :) = values(1, :);
  surpluses2(1, :) = values(1, :).^2;

  %
  % Summarize what we have done so far.
  %
  level = 2;
  gridNodeCount = 1;
  oldNodeCount = 2 * inputDimension;

  oldOrderIndex(1:oldNodeCount, :) = 1;
  for i = 1:inputDimension
    %
    % NOTE: The order of the left node is already one;
    % therefore, we initialize only the right node.
    %
    oldOrderIndex(2 * (i - 1) + 2, i) = 3;
  end

  levelNodeCount = zeros(maxLevel, 1);
  levelNodeCount(1) = 1;
  levelNodeCount(2) = 2 * inputDimension;

  %
  % Now, the other levels.
  %
  while true
    %
    % First, we always compute the surpluses of the old nodes.
    % These surpluses determine the parent nodes that are to be
    % refined. Consequently, if there are no old nodes, there
    % are no parents to refine, and we stop.
    %
    if oldNodeCount == 0, break; end

    %
    % Otherwise, the following range is to be processed.
    %
    oldNodeRange = (gridNodeCount + 1):(gridNodeCount + oldNodeCount);

    gridNodes = nodes(1:gridNodeCount, :);
    gridLevelIndex = levelIndex(1:gridNodeCount, :);
    gridIntervals = 2.^(double(gridLevelIndex) - 1);
    inverseGridIntervals = 1.0 ./ gridIntervals;

    delta = zeros(gridNodeCount, inputDimension);
    for i = oldNodeRange
      for j = 1:inputDimension
        delta(:, j) = abs(gridNodes(:, j) - nodes(i, j));
      end
      I = find(all(delta < inverseGridIntervals, 2));

      %
      % Ensure that all the (one-dimensional) bases function at
      % the first level are equal to one.
      %
      bases = 1.0 - gridIntervals(I, :) .* delta(I, :);
      bases(gridLevelIndex(I) == 1) = 1;
      bases = prod(bases, 2);

      surpluses (i, :) = ...
        values(i, :) - sum(bsxfun(@times, surpluses(I, :), bases), 1);
      surpluses2(i, :) = ...
        values(i, :).^2 - sum(bsxfun(@times, surpluses2(I, :), bases), 1);
    end

    %
    % If the current level is the last one, we do not try to add any
    % more nodes; just exit the loop.
    %
    if ~(level < maxLevel), break; end

    %
    % Since we are allowed to go to the next level, we seek
    % for new nodes defined as children of the old nodes where
    % the corresponding surpluses violate the accuracy constraint.
    %
    newNodeCount = 0;
    stepBufferLimit = oldNodeCount * 2 * inputDimension;

    %
    % Ensure that we have enough space.
    %
    if stepBufferSize < stepBufferLimit
      %
      % We need more space.
      %
      addition = max(stepBufferLimit, floor(bufferIncreaseFactor * stepBufferSize));
      stepBufferSize = stepBufferSize + addition;

      oldOrderIndex = [ oldOrderIndex; zeros(addition, inputDimension, 'uint32') ];
      newLevelIndex = zeros(stepBufferSize, inputDimension, 'uint8');
      newOrderIndex = zeros(stepBufferSize, inputDimension, 'uint32');
      newNodes      = zeros(stepBufferSize, inputDimension);
    end

    for i = oldNodeRange
      if level >= minLevel && max(abs(surpluses2(i, :))) < tolerance, continue; end

      %
      % So, the threshold is violated (or the minimal level has not been
      % reached yet); hence, we need to add all the neighbors.
      %

      currentLevelIndex = levelIndex(i, :);
      currentOrderIndex = oldOrderIndex(i - gridNodeCount, :);

      for j = 1:inputDimension
        [ childOrderIndex, childNodes ] = computeNeighbors( ...
          currentLevelIndex(j), currentOrderIndex(j));

        childCount = length(childOrderIndex);
        newNodeCount = newNodeCount + childCount;

        assert(newNodeCount <= stepBufferLimit);

        for k = 1:childCount
          l = newNodeCount - childCount + k;

          newLevelIndex(l, :) = currentLevelIndex;
          newLevelIndex(l, j) = currentLevelIndex(j) + 1;

          newOrderIndex(l, :) = currentOrderIndex;
          newOrderIndex(l, j) = childOrderIndex(k);

          newNodes(l, :) = nodes(i, :);
          newNodes(l, j) = childNodes(k);
        end
      end
    end

    %
    % The new nodes have been identify, but they might not be unique.
    % Therefore, we filter out the duplicates.
    %
    [ uniqueNewNodes, J1 ] = unique(newNodes(1:newNodeCount, :), 'rows');
    [ uniqueNewNodes, J2 ] = setdiff(uniqueNewNodes, nodes(1:nodeCount, :), 'rows');

    uniqueNewLevelIndex = newLevelIndex(J1, :);
    uniqueNewOrderIndex = newOrderIndex(J1, :);

    uniqueNewLevelIndex = uniqueNewLevelIndex(J2, :);
    uniqueNewOrderIndex = uniqueNewOrderIndex(J2, :);

    newNodeCount = size(uniqueNewNodes, 1);

    oldOrderIndex(1:newNodeCount, :) = uniqueNewOrderIndex;

    nodeCount = nodeCount + newNodeCount;

    if bufferSize < nodeCount
      %
      % We need more space.
      %
      addition = max(nodeCount, floor(bufferIncreaseFactor * bufferSize));

      levelIndex = [ levelIndex; zeros(addition, inputDimension, 'uint8') ];
      nodes      = [ nodes;      zeros(addition, inputDimension) ];
      values     = [ values;     zeros(addition, outputDimension) ];
      surpluses  = [ surpluses;  zeros(addition, outputDimension) ];
      surpluses2 = [ surpluses2; zeros(addition, outputDimension) ];

      bufferSize = bufferSize + addition;
    end

    range = (nodeCount - newNodeCount + 1):nodeCount;

    levelIndex(range, :) = uniqueNewLevelIndex;
    nodes     (range, :) = uniqueNewNodes;
    values    (range, :) = f(uniqueNewNodes);

    oldNodeCount  = nodeCount - gridNodeCount - oldNodeCount;
    gridNodeCount = nodeCount - oldNodeCount;

    level = level + 1;

    levelNodeCount(level) = newNodeCount;
  end

  %
  % Summarize.
  %
  range = 1:nodeCount;

  levelIndex = levelIndex(range, :);
  surpluses = surpluses(range, :);
  surpluses2 = surpluses2(range, :);

  %
  % Compute expectation and variance.
  %
  integrals = 2.^(1 - double(levelIndex));
  integrals(levelIndex == 1) = 1;
  integrals(levelIndex == 2) = 1 / 4;
  integrals = prod(integrals, 2);

  expectation = sum(bsxfun(@times, surpluses, integrals), 1);
  variance = sum(bsxfun(@times, surpluses2, integrals), 1) - expectation.^2;

  %
  % Save.
  %
  this.inputDimension = inputDimension;
  this.outputDimension = outputDimension;

  this.level = level;

  this.nodeCount = nodeCount;
  this.levelNodeCount = levelNodeCount(1:level);

  this.nodes = nodes(range, :);
  this.levelIndex = levelIndex;

  this.surpluses = surpluses;

  this.expectation = expectation;
  this.variance = variance;
end

function [ orderIndex, nodes ] = computeNeighbors(level, order)
  if level > 2
    orderIndex = uint32([ 2 * order - 2; 2 * order ]);
    nodes = double(orderIndex - 1) / 2^((double(level) + 1) - 1);
  elseif level == 2
    if order == 1
      orderIndex = uint32(2);
      nodes = 0.25;
    elseif order == 3
      orderIndex = uint32(4);
      nodes = 0.75;
    else
      assert(false);
    end
  elseif level == 1;
    assert(order == 1);
    orderIndex = uint32([ 1; 3 ]);
    nodes = [ 0.0; 1.0 ];
  else
    assert(false);
  end
end
