function output = construct(this, f, varargin)
  zeros = @uninit;

  options = Options(varargin{:});

  inputCount = options.inputCount;
  outputCount = options.get('outputCount', 1);
  control = options.get('control', 'NormNormExpectation');
  tolerance = options.get('tolerance', 1e-3);
  minimalLevel = options.get('minimalLevel', 2);
  maximalLevel = options.get('maximalLevel', 10);

  %
  % NOTE: We convert strings to numbers due to a possible speedup later on.
  %
  switch control
  case 'InfNorm'
    control = uint8(0);
  case 'InfNormSurpluses'
    control = uint8(1);
  case 'InfNormSurpluses2'
    control = uint8(2);
  case 'NormNormExpectation'
    control = uint8(3);
  otherwise
    error('The specified adaptivity control method is unknown.');
  end

  verbose = @(varargin) [];
  if options.get('verbose', false)
    verbose = @(varargin) fprintf(varargin{:});
  end

  bufferSize = 200 * inputCount;
  stepBufferSize = 100 * 2 * inputCount;

  %
  % Preallocate some memory such that we do need to reallocate
  % it at low levels. For high levels, we reallocate the memory
  % each time; however, since going from one high level to the
  % next one does not happen too often, we do not lose too much
  % of speed.
  %
  levelIndex = zeros(bufferSize, inputCount, 'uint8');
  nodes      = zeros(bufferSize, inputCount);
  values     = zeros(bufferSize, outputCount);
  surpluses  = zeros(bufferSize, outputCount);
  surpluses2 = zeros(bufferSize, outputCount);

  oldOrderIndex = zeros(stepBufferSize, inputCount, 'uint32');
  newLevelIndex = zeros(stepBufferSize, inputCount, 'uint8');
  newOrderIndex = zeros(stepBufferSize, inputCount, 'uint32');
  newNodes      = zeros(stepBufferSize, inputCount);

  %
  % The first two levels.
  %
  nodeCount = 1 + 2 * inputCount;

  levelIndex(1:nodeCount, :) = 1;
  nodes     (1:nodeCount, :) = 0.5;

  for i = 1:inputCount
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
  stableNodeCount = 1;
  oldNodeCount = 2 * inputCount;

  oldOrderIndex(1:oldNodeCount, :) = 1;
  for i = 1:inputCount
    %
    % NOTE: The order of the left node is already one;
    % therefore, we initialize only the right node.
    %
    oldOrderIndex(2 * (i - 1) + 2, i) = 3;
  end

  levelNodeCount = zeros(maximalLevel, 1);
  levelNodeCount(1) = 1;
  levelNodeCount(2) = 2 * inputCount;

  %
  % The first statistics.
  %
  expectation = surpluses(1, :);
  secondRawMoment = surpluses2(1, :);

  %
  % Now, the other levels.
  %
  while true
    verbose('Level %2d: stable %6d, old %6d, total %6d.\n', ...
      level, stableNodeCount, oldNodeCount, nodeCount);

    %
    % First, we always compute the surpluses of the old nodes.
    % These surpluses determine the parent nodes that are to be
    % refined.
    %
    oldNodeRange = (stableNodeCount + 1):(stableNodeCount + oldNodeCount);

    stableLevelIndex = levelIndex(1:stableNodeCount, :);
    intervals = 2.^(double(stableLevelIndex) - 1);
    inverseIntervals = 1.0 ./ intervals;

    delta = zeros(stableNodeCount, inputCount);
    for i = oldNodeRange
      for j = 1:inputCount
        delta(:, j) = abs(nodes(1:stableNodeCount, j) - nodes(i, j));
      end
      I = find(all(delta < inverseIntervals, 2));

      %
      % Ensure that all the (one-dimensional) basis functions at
      % the first level are equal to one.
      %
      bases = 1.0 - intervals(I, :) .* delta(I, :);
      bases(stableLevelIndex(I, :) == 1) = 1;
      bases = prod(bases, 2);

      surpluses (i, :) = values(i, :) - ...
        sum(bsxfun(@times, surpluses(I, :), bases), 1);
      surpluses2(i, :) = values(i, :).^2 - ...
        sum(bsxfun(@times, surpluses2(I, :), bases), 1);
    end

    %
    % Now, we take care about the expected value and variance, which
    % also surve error estimates. But, BEFORE doing so, we should compute
    % the norm of the current expectation for the future error control.
    %
    expectationNorm = norm(expectation);
    assert(expectationNorm > 0);

    oldLevelIndex = levelIndex(oldNodeRange, :);

    integrals = 2.^(1 - double(oldLevelIndex));
    %
    % NOTE: We do not need the following line; keep for clarity.
    %
    % integrals(oldLevelIndex == 1) = 1;
    %
    integrals(oldLevelIndex == 2) = 0.25;
    integrals = prod(integrals, 2);

    %
    % Expectations and variances from each `old' node individually.
    %
    oldExpectations = ...
      bsxfun(@times, surpluses(oldNodeRange, :), integrals);
    oldSecondRawMoments = ...
      bsxfun(@times, surpluses2(oldNodeRange, :), integrals);

    %
    % Add the individual statistics to the overall ones.
    %
    expectation = expectation + sum(oldExpectations, 1);
    secondRawMoment = secondRawMoment + sum(oldSecondRawMoments, 1);

    %
    % If the current level is the last one, we do not try to add any
    % more nodes; just exit the loop.
    %
    if ~(level < maximalLevel), break; end

    %
    % Since we are allowed to go to the next level, we seek
    % for new nodes defined as children of the old nodes where
    % the corresponding surpluses violate the accuracy constraint.
    %
    newNodeCount = 0;
    stepBufferLimit = oldNodeCount * 2 * inputCount;

    %
    % Ensure that we have enough space.
    %
    addition = stepBufferLimit - stepBufferSize;
    if addition > 0
      %
      % We need more space.
      %
      oldOrderIndex = [ oldOrderIndex; ...
        zeros(addition, inputCount, 'uint32') ];
      newLevelIndex = [ newLevelIndex; ...
        zeros(addition, inputCount, 'uint8') ];
      newOrderIndex = [ newOrderIndex; ...
        zeros(addition, inputCount, 'uint32') ];
      newNodes      = [ newNodes; ...
        zeros(addition, inputCount) ];

      stepBufferSize = stepBufferSize + addition;
    end

    %
    % Adaptivity control.
    %
    switch control
    case 0 % Infinity norm of surpluses and surpluses2
      nodeContribution = ...
        max(abs([ surpluses(oldNodeRange, :) surpluses2(oldNodeRange, :) ]), [], 2);
    case 1 % Infinity norm of surpluses
      nodeContribution = max(abs(surpluses(oldNodeRange, :)), [], 2);
    case 2 % Infinity norm of squared surpluses
      nodeContribution = max(abs(surpluses2(oldNodeRange, :)), [], 2);
    case 3 % Normalized norm of expectation
      nodeContribution = sqrt(sum(oldExpectations.^2, 2)) / expectationNorm;
    otherwise
      assert(false);
    end

    for i = oldNodeRange
      if level >= minimalLevel && ...
        nodeContribution(i - stableNodeCount) < tolerance, continue; end

      %
      % So, the threshold is violated (or the minimal level has not been
      % reached yet); hence, we need to add all the neighbors.
      %
      currentLevelIndex = levelIndex(i, :);
      currentOrderIndex = oldOrderIndex(i - stableNodeCount, :);
      currentNode = nodes(i, :);

      for j = 1:inputCount
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

          newNodes(l, :) = currentNode;
          newNodes(l, j) = childNodes(k);
        end
      end
    end

    %
    % The new nodes have been identify, but they might not be unique.
    % Therefore, we need to filter out all duplicates.
    %
    [ uniqueNewNodes, I ] = unique(newNodes(1:newNodeCount, :), 'rows');
    uniqueNewLevelIndex = newLevelIndex(I, :);
    uniqueNewOrderIndex = newOrderIndex(I, :);

    newNodeCount = size(uniqueNewNodes, 1);

    %
    % If there are no more nodes to refine, we stop.
    %
    if newNodeCount == 0, break; end

    oldOrderIndex(1:newNodeCount, :) = uniqueNewOrderIndex;

    nodeCount = nodeCount + newNodeCount;

    addition = nodeCount - bufferSize;
    if addition > 0
      %
      % We need more space.
      %
      levelIndex = [ levelIndex; ...
        zeros(addition, inputCount, 'uint8') ];
      nodes      = [ nodes; ...
        zeros(addition, inputCount) ];
      values     = [ values; ...
        zeros(addition, outputCount) ];
      surpluses  = [ surpluses; ...
        zeros(addition, outputCount) ];
      surpluses2 = [ surpluses2; ...
        zeros(addition, outputCount) ];

      bufferSize = bufferSize + addition;
    end

    range = (nodeCount - newNodeCount + 1):nodeCount;

    levelIndex(range, :) = uniqueNewLevelIndex;
    nodes     (range, :) = uniqueNewNodes;
    values    (range, :) = f(uniqueNewNodes);

    oldNodeCount  = nodeCount - stableNodeCount - oldNodeCount;
    stableNodeCount = nodeCount - oldNodeCount;

    %
    % We go to the next level.
    %
    level = level + 1;
    levelNodeCount(level) = newNodeCount;
  end

  %
  % Save the result.
  %
  range = 1:nodeCount;

  output = struct;

  output.inputCount = inputCount;
  output.outputCount = outputCount;

  output.level = level;
  output.nodeCount = nodeCount;
  output.levelNodeCount = levelNodeCount(1:level);

  output.nodes = nodes(range, :);
  output.levelIndex = levelIndex(range, :);

  output.surpluses = surpluses(range, :);

  output.expectation = expectation;
  output.variance = secondRawMoment - expectation.^2;
  output.secondRawMoment = secondRawMoment;
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
