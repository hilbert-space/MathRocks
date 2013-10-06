function output = construct(this, f, outputCount)
  zeros = @uninit;

  basis = this.basis;

  inputCount = this.inputCount;
  if nargin < 3, outputCount = this.outputCount; end

  control = this.control;
  tolerance = this.tolerance;

  minimalLevel = this.minimalLevel;
  maximalLevel = this.maximalLevel;

  verbose = this.verbose;

  bufferSize = 200 * inputCount;
  stepBufferSize = 100 * 2 * inputCount;

  %
  % Preallocate some memory such that we do not need to reallocate
  % it at low levels. For high levels, we reallocate the memory
  % each time; however, since going from one high level to the
  % next one does not happen too often, we do not lose too much.
  %
  levels    = zeros(bufferSize, inputCount);
  nodes     = zeros(bufferSize, inputCount);
  values    = zeros(bufferSize, outputCount);
  surpluses = zeros(bufferSize, outputCount);

  oldOrders = zeros(stepBufferSize, inputCount);
  newLevels = zeros(stepBufferSize, inputCount);
  newOrders = zeros(stepBufferSize, inputCount);
  newNodes  = zeros(stepBufferSize, inputCount);

  %
  % The first two levels.
  %
  nodeCount = 1 + 2 * inputCount;

  levels(1:nodeCount, :) = 1;
  nodes (1:nodeCount, :) = 0.5;

  for i = 1:inputCount
    %
    % The left and right most nodes.
    %
    k = 1 + 2 * (i - 1) + 1;
    levels(k:(k + 1), i) = 2;
    nodes (k:(k + 1), i) = [ 0.0; 1.0 ];
  end

  %
  % Evaluate the function on the first two levels.
  %
  values(1:nodeCount, :) = f(nodes(1:nodeCount, :));
  surpluses(1, :) = values(1, :);

  %
  % Summarize what we have done so far.
  %
  level = 2;
  stableNodeCount = 1;
  oldNodeCount = 2 * inputCount;

  oldOrders(1:oldNodeCount, :) = 1;
  for i = 1:inputCount
    %
    % NOTE: The order of the left node is already one;
    % therefore, we initialize only the right node.
    %
    oldOrders(2 * (i - 1) + 2, i) = 3;
  end

  levelNodeCount = zeros(maximalLevel, 1);
  levelNodeCount(1) = 1;
  levelNodeCount(2) = 2 * inputCount;

  %
  % The first statistics.
  %
  expectation = surpluses(1, :);

  %
  % Now, the other levels.
  %
  while true
    if verbose
      fprintf('Level %2d: stable %6d, old %6d, total %6d\n', ...
        level, stableNodeCount, oldNodeCount, nodeCount);
    end

    %
    % First, we always compute the surpluses of the old nodes.
    % These surpluses determine the parent nodes that are to be
    % refined.
    %
    oldNodeRange = (stableNodeCount + 1):(stableNodeCount + oldNodeCount);

    stableLevels = levels(1:stableNodeCount, :);
    intervals = 2.^(double(stableLevels) - 1) + 1;
    inversed = 1 ./ (intervals - 1);

    delta = zeros(stableNodeCount, inputCount);
    for i = oldNodeRange
      for j = 1:inputCount
        delta(:, j) = abs(nodes(1:stableNodeCount, j) - nodes(i, j));
      end
      I = find(all(delta < inversed, 2));

      %
      % Ensure that all the (one-dimensional) basis functions at
      % the first level are equal to one.
      %
      bases = 1 - (intervals(I, :) - 1) .* delta(I, :);
      bases(stableLevels(I, :) == 1) = 1;
      bases = prod(bases, 2);

      surpluses (i, :) = values(i, :) - ...
        sum(bsxfun(@times, surpluses(I, :), bases), 1);
    end

    %
    % Now, we shall take care of the expected value, which also surve
    % error estimates. But, BEFORE doing so, we should compute the norm
    % of the current expectation for the future error control.
    %
    expectationNorm = norm(expectation);
    % assert(expectationNorm > 0);

    oldLevels = levels(oldNodeRange, :);

    %
    % Expectation
    %
    integrals1 = 2.^(1 - double(oldLevels));
    % integrals1(oldLevels == 1) = 1;
    integrals1(oldLevels == 2) = 1 / 4;
    integrals1 = prod(integrals1, 2);

    oldExpectations = bsxfun(@times, ...
      surpluses(oldNodeRange, :), integrals1);
    expectation = expectation + sum(oldExpectations, 1);

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
      oldOrders = [ oldOrders; zeros(addition, inputCount) ];
      newLevels = [ newLevels; zeros(addition, inputCount) ];
      newOrders = [ newOrders; zeros(addition, inputCount) ];
      newNodes  = [ newNodes; zeros(addition, inputCount) ];

      stepBufferSize = stepBufferSize + addition;
    end

    %
    % Adaptivity control.
    %
    switch control
    case 'InfNormSurpluses' % Infinity norm of surpluses
      nodeContribution = max(abs(surpluses(oldNodeRange, :)), [], 2);
    case 'NormNormExpectation' % Normalized norm of expectation
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
      currentLevels = levels(i, :);
      currentOrders = oldOrders(i - stableNodeCount, :);
      currentNode = nodes(i, :);

      for j = 1:inputCount
        [ childNodes, childOrders ] = basis.computeChildNodes( ...
          currentLevels(j), currentOrders(j));

        childCount = length(childOrders);
        newNodeCount = newNodeCount + childCount;

        assert(newNodeCount <= stepBufferLimit);

        for k = 1:childCount
          l = newNodeCount - childCount + k;

          newLevels(l, :) = currentLevels;
          newLevels(l, j) = currentLevels(j) + 1;

          newOrders(l, :) = currentOrders;
          newOrders(l, j) = childOrders(k);

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
    uniqueNewLevels = newLevels(I, :);
    uniqueNewOrders = newOrders(I, :);

    newNodeCount = size(uniqueNewNodes, 1);

    %
    % If there are no more nodes to refine, we stop.
    %
    if newNodeCount == 0, break; end

    oldOrders(1:newNodeCount, :) = uniqueNewOrders;

    nodeCount = nodeCount + newNodeCount;

    addition = nodeCount - bufferSize;
    if addition > 0
      %
      % We need more space.
      %
      levels    = [ levels; zeros(addition, inputCount) ];
      nodes     = [ nodes; zeros(addition, inputCount) ];
      values    = [ values; zeros(addition, outputCount) ];
      surpluses = [ surpluses; zeros(addition, outputCount) ];

      bufferSize = bufferSize + addition;
    end

    range = (nodeCount - newNodeCount + 1):nodeCount;

    levels(range, :) = uniqueNewLevels;
    nodes (range, :) = uniqueNewNodes;
    values(range, :) = f(uniqueNewNodes);

    oldNodeCount = nodeCount - stableNodeCount - oldNodeCount;
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
  output.levels = levels(range, :);

  output.surpluses = surpluses(range, :);

  output.expectation = expectation;
  output.variance = zeros(1, outputCount);
end
