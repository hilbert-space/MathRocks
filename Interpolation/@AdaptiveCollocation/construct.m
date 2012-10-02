function construct(this, f, options)
  dimensionCount = 2;
  tolerance = 1e-3;
  maxLevel = options.get('maxLevel', 10);

  bufferScale = 0.5;
  levelBufferSize = 10 * dimensionCount;
  pointBufferSize = 20 * dimensionCount;
  newBufferSize = 10 * 2 * dimensionCount;

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
  % Evaluate the functions on the first two levels.
  %
  values(1:nodeCount) = f(nodes(1:nodeCount, :));
  surpluses(1) = values(1);

  gridNodeCount = 1;
  oldNodeCount = 2 * dimensionCount;

  %
  % The other levels.
  %
  level = 2;
  while level < maxLevel
    %
    % NOTE: We skip the first one since it represents the very first level
    % where all the basis functions are equal to one.
    %
    gridNodes = nodes(2:gridNodeCount, :);
    gridIntervals = double(2.^(levelIndex(levelMapping(2:gridNodeCount), :) - 1));

    %
    % Evaluate the interpolant, which was constructed on the passive points,
    % at the new points.
    %
    newNodeCount = 0;

    newBufferLimit = oldNodeCount * 2 * dimensionCount;
    if newBufferSize < newBufferLimit
      %
      % We need more space.
      %
      addition = floor(bufferScale * newBufferSize);
      newBufferSize = newBufferSize + addition;

      newLevelIndex = zeros(newBufferSize, dimensionCount, 'uint8');
      newOrderIndex = zeros(newBufferSize, dimensionCount, 'uint8');
      newNodes = zeros(newBufferSize, dimensionCount);
    end

    for i = (gridNodeCount + 1):(gridNodeCount + oldNodeCount)
      delta = abs(repmat(nodes(i, :), gridNodeCount - 1, 1) - gridNodes);
      mask = delta < 1.0 ./ gridIntervals;
      basis = [ 1; prod((1.0 - gridIntervals .* delta) .* mask, 2) ];
      surpluses(i) = values(i) - sum(surpluses(1:gridNodeCount) .* basis);

      if abs(surpluses(i)) > tolerance
        %
        % The threshold is violated; hence, we need to add all
        % the neighbors.
        %

        k = levelMapping(i);
        for j = 1:dimensionCount
          %
          % The indexes of the children across all the nodes.
          %
          [ childOrderIndex, childNodes ] = computeNeighbors( ...
            levelIndex(k, j), orderIndex(i, j));

          childCount = length(childOrderIndex);
          newNodeCount = newNodeCount + childCount;

          assert(newNodeCount <= newBufferLimit);

          range = (newNodeCount - childCount + 1):newNodeCount;

          newLevelIndex(range, :) = repmat(levelIndex(k, :), childCount, 1);
          newLevelIndex(range, j) = newLevelIndex(range, j) + 1;

          newOrderIndex(range, :) = repmat(orderIndex(i, :), childCount, 1);
          newOrderIndex(range, j) = childOrderIndex;

          newNodes(range, :) = repmat(nodes(i, :), childCount, 1);
          newNodes(range, j) = childNodes;
        end
      end
    end

    [ uniqueNewNodes, J ] = unique(newNodes(1:newNodeCount, :), 'rows');
    newNodeCount = length(J);

    uniqueNewLevelIndex = newLevelIndex(J, :);
    uniqueNewOrderIndex = newOrderIndex(J, :);

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
      addition = floor(bufferScale * levelBufferSize);

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
      addition = floor(bufferScale * pointBufferSize);

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

    if oldNodeCount == 0, break; end
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
  if level == 1
    assert(order == 1);
    orderIndex = uint8([ 1; 3 ]);
    nodes = [ 0.0; 1.0 ];
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
  else
    orderIndex = uint8([ 2 * order - 2; 2 * order ]);
    count = 2^((level + 1) - 1) + 1;
    nodes = double(orderIndex - 1) / double(count - 1);
  end
end
