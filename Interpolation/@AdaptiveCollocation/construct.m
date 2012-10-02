function construct(this, f, options)
  dimensionCount = 2;
  tolerance = 1e-3;
  maxLevel = 10;

  bufferScale = 0.5;
  iBufferSize = 10 * dimensionCount;
  jBufferSize = 20 * dimensionCount;
  newBufferSize = 10 * 2 * dimensionCount;

  %
  % Allocate some memory.
  %
  iIndex = zeros(iBufferSize, dimensionCount, 'uint8');
  jIndex = zeros(jBufferSize, dimensionCount, 'uint8');
  iMapping = zeros(jBufferSize, 1, 'uint8');
  nodes = zeros(jBufferSize, dimensionCount);
  values = zeros(jBufferSize, 1);

  newIIndex = zeros(newBufferSize, dimensionCount, 'uint8');
  newJIndex = zeros(newBufferSize, dimensionCount, 'uint8');
  newNodes = zeros(newBufferSize, dimensionCount);

  %
  % The first two levels.
  %
  nodeCount = 1 + 2 * dimensionCount;
  iIndexCount = 1 + dimensionCount;

  iIndex(1:iIndexCount, :) = 1;
  jIndex(1:nodeCount, :) = 1;

  iMapping(1) = 1;
  iMapping(1 + (1:2:(2 * dimensionCount))    ) = 2:(dimensionCount + 1);
  iMapping(1 + (1:2:(2 * dimensionCount)) + 1) = 2:(dimensionCount + 1);

  nodes(1:nodeCount, :) = 0.5;

  for i = 1:dimensionCount
    iIndex(1 + i, i) = 2;

    %
    % The left most.
    %
    jIndex(1 + 2 * (i - 1) + 1, i) = 1;
    nodes (1 + 2 * (i - 1) + 1, i) = 0.0;

    %
    % The right most.
    %
    jIndex(1 + 2 * (i - 1) + 2, i) = 3;
    nodes (1 + 2 * (i - 1) + 2, i) = 1.0;
  end

  %
  % Evaluate the functions on the first two levels.
  %
  values(1:nodeCount) = f(nodes(1:nodeCount, :));

  passiveCount = 1;
  activeCount = 2 * dimensionCount;

  %
  % The other levels.
  %
  level = 2;
  while level < maxLevel
    %
    % NOTE: We skip the first one since it represents the very first level
    % where all the basis functions are equal to one.
    %
    passiveNodes = nodes(2:passiveCount, :);
    passiveIntervals = double(2.^(iIndex(iMapping(2:passiveCount), :) - 1));

    %
    % Evaluate the interpolant, which was constructed on the passive points,
    % at the active points.
    %
    newNodeCount = 0;

    if newBufferSize < activeCount * 2 * dimensionCount
      %
      % We need more space.
      %
      addition = floor(bufferScale * newBufferSize);
      newBufferSize = newBufferSize + addition;

      newIIndex = zeros(newBufferSize, dimensionCount, 'uint8');
      newJIndex = zeros(newBufferSize, dimensionCount, 'uint8');
      newNodes = zeros(newBufferSize, dimensionCount);
    end

    for i = (passiveCount + 1):(passiveCount + activeCount)
      if level > 2
        delta = abs(repmat(nodes(i, :), passiveCount - 1, 1) - passiveNodes);
        mask = delta < 1 ./ passiveIntervals;
        basis = [ 1; prod((1 - passiveIntervals .* delta) .* mask, 2) ];
        surplus = abs(values(i) - sum(values(1:passiveCount) .* basis));
      else
        %
        % We always refine low levels.
        %
        surplus = Inf;
      end

      if surplus > tolerance
        %
        % The threshold is violated; hence, we need to add all
        % the neigbors, and the neighbors are almost the same as
        % the current node except a small change.
        %

        iI = iMapping(i);
        for j = 1:dimensionCount
          %
          % The indexes of the children across all the nodes.
          %
          [ childJIndex, childNodes ] = computeNeighbors( ...
            iIndex(iI, j), jIndex(i, j));

          childCount = length(childJIndex);
          newNodeCount = newNodeCount + childCount;

          assert(newNodeCount <= activeCount * 2 * dimensionCount);

          range = (newNodeCount - childCount + 1):newNodeCount;

          newIIndex(range, :) = repmat(iIndex(iI, :), childCount, 1);
          newIIndex(range, j) = newIIndex(range, j) + 1;

          newJIndex(range, :) = repmat(jIndex(i, :), childCount, 1);
          newJIndex(range, j) = childJIndex;

          newNodes(range, :) = repmat(nodes(i, :), childCount, 1);
          newNodes(range, j) = childNodes;
        end
      end
    end

    [ uniqueNewNodes, J ] = unique(newNodes(1:newNodeCount, :), 'rows');
    newNodeCount = length(J);

    uniqueNewIIndex = newIIndex(J, :);
    uniqueNewJIndex = newJIndex(J, :);

    [ uniqueNewIIndex, I, II ] = unique(uniqueNewIIndex, 'rows');
    newIIndexCount = length(I);

    uniqueNewIMapping = II + iIndexCount;

    %
    % Process the i-indexes.
    %
    iIndexCount = iIndexCount + newIIndexCount;
    while iIndexCount > iBufferSize
      %
      % We need more space.
      %
      addition = floor(bufferScale * iBufferSize);

      iIndex = [ iIndex; zeros(addition, dimensionCount, 'uint8') ];

      iBufferSize = iBufferSize + addition;
    end

    iIndex((iIndexCount - newIIndexCount + 1):iIndexCount, :) = uniqueNewIIndex;

    %
    % Process the nodes.
    %
    nodeCount = nodeCount + newNodeCount;
    while nodeCount > jBufferSize
      %
      % We need more space.
      %
      addition = floor(bufferScale * jBufferSize);

      jIndex = [ jIndex; zeros(addition, dimensionCount, 'uint8') ];
      iMapping = [ iMapping; zeros(addition, 1, 'uint8') ];
      nodes = [ nodes; zeros(addition, dimensionCount) ];
      values = [ values; zeros(addition, 1) ];

      jBufferSize = jBufferSize + addition;
    end

    range = (nodeCount - newNodeCount + 1):nodeCount;

    jIndex(range, :) = uniqueNewJIndex;
    iMapping(range) = uniqueNewIMapping;
    nodes(range, :) = uniqueNewNodes;
    values(range) = f(uniqueNewNodes);

    activeCount = nodeCount - passiveCount - activeCount;
    passiveCount = nodeCount - activeCount;

    level = level + 1;

    if activeCount == 0, break; end
  end

  this.nodes = nodes;
end

function [ jIndex, nodes ] = computeNeighbors(i, j)
  if i == 1
    assert(j == 1);
    jIndex = uint8([ 1; 3 ]);
    nodes = [ 0.0; 1.0 ];
  elseif i == 2
    if j == 1
      jIndex = uint8(2);
      nodes = 0.25;
    elseif j == 3
      jIndex = uint8(4);
      nodes = 0.75;
    else
      assert(false);
    end
  else
    jIndex = uint8([ 2 * j - 2; 2 * j ]);
    count = 2^((i + 1) - 1) + 1;
    nodes = double(jIndex - 1) / double(count - 1);
  end
end
