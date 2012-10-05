function construct(this, f, options)
  dimensionCount = options.dimensionCount;
  tolerance = options.get('tolerance', 1e-3);
  minLevel = options.get('minLevel', 2);
  maxLevel = options.get('maxLevel', 10);

  bufferIncreaseFactor = 1;
  levelBufferSize = 100 * dimensionCount;
  pointBufferSize = 200 * dimensionCount;
  newBufferSize = 100 * 2 * dimensionCount;

  %
  % Allocate some memory.
  %
  levelIndex = zeros(levelBufferSize, dimensionCount, 'uint8');
  orderIndex = zeros(pointBufferSize, dimensionCount, 'uint16');
  levelMapping = zeros(pointBufferSize, 1, 'uint8');
  nodes = zeros(pointBufferSize, dimensionCount);
  values = zeros(pointBufferSize, 1);
  surpluses = zeros(pointBufferSize, 1);
  surpluses2 = zeros(pointBufferSize, 1);

  newLevelIndex = zeros(newBufferSize, dimensionCount, 'uint8');
  newOrderIndex = zeros(newBufferSize, dimensionCount, 'uint8');
  newNodes = zeros(newBufferSize, dimensionCount);

  %
  % The first two levels.
  %
  nodeCount = 1 + 2 * dimensionCount;
  levelIndexCount = 1 + dimensionCount;

  levelIndex(1:levelIndexCount, :) = 1;
  orderIndex(1:nodeCount, :) = 1;

  levelMapping(1) = 1;
  levelMapping(1 + (1:2:(2 * dimensionCount))    ) = 1 + (1:dimensionCount);
  levelMapping(1 + (1:2:(2 * dimensionCount)) + 1) = 1 + (1:dimensionCount);

  nodes(1:nodeCount, :) = 0.5;

  for i = 1:dimensionCount
    levelIndex(1 + i, i) = 2;

    %
    % The left most.
    %
    orderIndex(1 + 2 * (i - 1) + 1, i) = 1;
    nodes     (1 + 2 * (i - 1) + 1, i) = 0.0;

    %
    % The right most.
    %
    orderIndex(1 + 2 * (i - 1) + 2, i) = 3;
    nodes     (1 + 2 * (i - 1) + 2, i) = 1.0;
  end

  %
  % Evaluate the function on the first two levels.
  %
  values(1:nodeCount) = f(nodes(1:nodeCount, :));
  surpluses (1) = values(1);
  surpluses2(1) = values(1).^2;

  %
  % Summarize what we have done up until now.
  %
  level = 2;
  gridNodeCount = 1;
  oldNodeCount = 2 * dimensionCount;

  levelNodeCount = zeros(maxLevel, 1);
  levelNodeCount(1) = 1;
  levelNodeCount(2) = 2 * dimensionCount;

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
    gridLevels = levelIndex(levelMapping(1:gridNodeCount), :);
    gridIntervals = 2.^(double(gridLevels) - 1);

    delta = zeros(gridNodeCount, dimensionCount);
    for i = oldNodeRange
      for j = 1:dimensionCount
        delta(:, j) = abs(gridNodes(:, j) - nodes(i, j));
      end
      I = find(all(delta < 1.0 ./ gridIntervals, 2));

      %
      % Ensure that all the (one-dimensional) bases function at
      % the first level are equal to one.
      %
      bases = 1.0 - gridIntervals(I, :) .* delta(I, :);
      bases(find(gridLevels(I) == 1)) = 1;
      bases = prod(bases, 2);

      surpluses(i) = values(i) - sum(surpluses(I) .* bases);
      surpluses2(i) = values(i).^2 - sum(surpluses2(I) .* bases);
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
    newBufferLimit = oldNodeCount * 2 * dimensionCount;

    %
    % Ensure that we have enough space.
    %
    if newBufferSize < newBufferLimit
      %
      % We need more space.
      %
      addition = floor(bufferIncreaseFactor * newBufferSize);
      newBufferSize = newBufferSize + addition;

      newLevelIndex = zeros(newBufferSize, dimensionCount, 'uint8');
      newOrderIndex = zeros(newBufferSize, dimensionCount, 'uint8');
      newNodes = zeros(newBufferSize, dimensionCount);
    end

    for i = oldNodeRange
      if level >= minLevel && abs(surpluses2(i)) < tolerance, continue; end

      %
      % So, the threshold is violated (or the minimal level has not been
      % reached yet); hence, we need to add all the neighbors.
      %

      currentOrderIndex = orderIndex(i, :);
      currentLevelIndex = levelIndex(levelMapping(i), :);

      for j = 1:dimensionCount
        [ childOrderIndex, childNodes ] = computeNeighbors( ...
          currentLevelIndex(j), currentOrderIndex(j));

        childCount = length(childOrderIndex);
        newNodeCount = newNodeCount + childCount;

        assert(newNodeCount <= newBufferLimit);

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

    newNodeCount = size(uniqueNewNodes, 1);

    uniqueNewLevelIndex = newLevelIndex(J1, :);
    uniqueNewLevelIndex = uniqueNewLevelIndex(J2, :);

    uniqueNewOrderIndex = newOrderIndex(J1, :);
    uniqueNewOrderIndex = uniqueNewOrderIndex(J2, :);

    [ uniqueNewLevelIndex, I, II ] = ...
      unique(uniqueNewLevelIndex, 'rows');

    newLevelIndexCount = length(I);
    uniqueNewLevelMapping = II + levelIndexCount;

    %
    % Process the level index.
    %
    levelIndexCount = levelIndexCount + newLevelIndexCount;
    while levelIndexCount > levelBufferSize
      %
      % We need more space.
      %
      addition = floor(bufferIncreaseFactor * levelBufferSize);

      levelIndex = [ levelIndex; zeros(addition, dimensionCount, 'uint8') ];

      levelBufferSize = levelBufferSize + addition;
    end

    levelIndex((levelIndexCount - newLevelIndexCount + 1):levelIndexCount, :) = ...
      uniqueNewLevelIndex;

    %
    % Process the nodes and the rest.
    %
    nodeCount = nodeCount + newNodeCount;
    while nodeCount > pointBufferSize
      %
      % We need more space.
      %
      addition = floor(bufferIncreaseFactor * pointBufferSize);

      orderIndex = [ orderIndex; zeros(addition, dimensionCount, 'uint16') ];
      levelMapping = [ levelMapping; zeros(addition, 1, 'uint8') ];
      nodes = [ nodes; zeros(addition, dimensionCount) ];
      values = [ values; zeros(addition, 1) ];
      surpluses = [ surpluses; zeros(addition, 1) ];
      surpluses2 = [ surpluses2; zeros(addition, 1) ];

      pointBufferSize = pointBufferSize + addition;
    end

    range = (nodeCount - newNodeCount + 1):nodeCount;

    orderIndex(range, :) = uniqueNewOrderIndex;
    levelMapping(range) = uniqueNewLevelMapping;
    nodes(range, :) = uniqueNewNodes;
    values(range) = f(uniqueNewNodes);

    oldNodeCount  = nodeCount - gridNodeCount - oldNodeCount;
    gridNodeCount = nodeCount - oldNodeCount;

    level = level + 1;

    levelNodeCount(level) = newNodeCount;
  end

  %
  % Summarize.
  %
  range = 1:nodeCount;

  levelIndex = levelIndex(levelMapping(range), :);
  surpluses = surpluses(range, :);
  surpluses2 = surpluses2(range, :);

  %
  % Compute expectation and variance.
  %
  integrals = 2.^(1 - double(levelIndex));
  integrals(find(levelIndex == 1)) = 1;
  integrals(find(levelIndex == 2)) = 1 / 4;
  integrals = prod(integrals, 2);

  expectation = sum(surpluses .* integrals);
  variance = sum(surpluses2 .* integrals) - expectation.^2;

  %
  % Save.
  %
  this.dimensionCount = dimensionCount;

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
    orderIndex = uint16([ 2 * order - 2; 2 * order ]);
    nodes = double(orderIndex - 1) / 2^((double(level) + 1) - 1);
  elseif level == 2
    if order == 1
      orderIndex = uint16(2);
      nodes = 0.25;
    elseif order == 3
      orderIndex = uint16(4);
      nodes = 0.75;
    else
      assert(false);
    end
  elseif level == 1;
    assert(order == 1);
    orderIndex = uint8([ 1; 3 ]);
    nodes = [ 0.0; 1.0 ];
  else
    assert(false);
  end
end
