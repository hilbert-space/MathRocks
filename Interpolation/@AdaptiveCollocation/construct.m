function construct(this, f, options)
  dimensionCount = 2;
  tolerance = options.get('tolerance', 1e-3);
  maxLevel = options.get('maxLevel', 10);

  bufferIncreaseFactor = 1;
  levelBufferSize = 100 * dimensionCount;
  pointBufferSize = 200 * dimensionCount;
  newBufferSize = 100 * 2 * dimensionCount;

  %
  % Allocate some memory.
  %
  levelIndex = zeros(levelBufferSize, dimensionCount, 'uint8');
  orderIndex = zeros(pointBufferSize, dimensionCount, 'uint8');
  levelMapping = zeros(pointBufferSize, 1, 'uint8');
  nodes = zeros(pointBufferSize, dimensionCount);
  values = zeros(pointBufferSize, 1);
  surpluses = zeros(pointBufferSize, 1);

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
  levelMapping(1 + (1:2:(2 * dimensionCount))    ) = 2:(dimensionCount + 1);
  levelMapping(1 + (1:2:(2 * dimensionCount)) + 1) = 2:(dimensionCount + 1);

  nodes(1:nodeCount, :) = 0.5;

  for i = 1:dimensionCount
    levelIndex(1 + i, i) = 2;

    %
    % The left most.
    %
    orderIndex(1 + 2 * (i - 1) + 1, i) = 1;
    nodes(1 + 2 * (i - 1) + 1, i) = 0.0;

    %
    % The right most.
    %
    orderIndex(1 + 2 * (i - 1) + 2, i) = 3;
    nodes(1 + 2 * (i - 1) + 2, i) = 1.0;
  end

  %
  % Evaluate the function on the first two levels.
  %
  values(1:nodeCount) = f(nodes(1:nodeCount, :));
  surpluses(1) = values(1);

  %
  % Summarize.
  %
  level = 2;
  gridNodeCount = 1;
  oldNodeCount = 2 * dimensionCount;

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

    %
    % NOTE: We skip the first node here since it represents the very
    % first level where all the basis functions are equal to one.
    %
    gridNodes = nodes(2:gridNodeCount, :);
    gridIntervals = double(2.^(levelIndex(levelMapping(2:gridNodeCount), :) - 1));

    for i = oldNodeRange
      delta = abs(repmat(nodes(i, :), gridNodeCount - 1, 1) - gridNodes);
      mask = delta < 1.0 ./ gridIntervals;
      basis = [ 1; prod((1.0 - gridIntervals .* delta) .* mask, 2) ];
      surpluses(i) = values(i) - sum(surpluses(1:gridNodeCount) .* basis);
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
      if ~(abs(surpluses(i)) > tolerance), continue; end

      %
      % So, the threshold is violated; hence, we need to add
      % all the neighbors.
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

      orderIndex = [ orderIndex; zeros(addition, dimensionCount, 'uint8') ];
      levelMapping = [ levelMapping; zeros(addition, 1, 'uint8') ];
      nodes = [ nodes; zeros(addition, dimensionCount) ];
      values = [ values; zeros(addition, 1) ];
      surpluses = [ surpluses; zeros(addition, 1) ];

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
  end

  this.dimensionCount = dimensionCount;
  this.nodeCount = nodeCount;
  this.lastNodeCount = oldNodeCount;
  this.nodes = nodes(1:nodeCount, :);

  this.evaluationNodes = nodes(2:nodeCount, :);
  this.evaluationIntervals = ...
    double(2.^(levelIndex(levelMapping(2:nodeCount), :) - 1));
  this.surpluses = surpluses(1:nodeCount, :);
end

function [ orderIndex, nodes ] = computeNeighbors(level, order)
  if level > 2
    orderIndex = uint8([ 2 * order - 2; 2 * order ]);
    count = 2^((level + 1) - 1) + 1;
    nodes = double(orderIndex - 1) / double(count - 1);
  elseif level == 2
    if order == 1
      orderIndex = uint8(2);
      nodes = 0.25;
    elseif order == 3
      orderIndex = uint8(4);
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
