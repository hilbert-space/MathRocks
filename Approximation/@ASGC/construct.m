function output = construct(this, f, outputCount)
  zeros = @uninit;

  basis = this.basis;

  inputCount = this.inputCount;
  if nargin < 3, outputCount = this.outputCount; end

  tolerance = this.tolerance;

  minimalLevel = this.minimalLevel;
  maximalLevel = this.maximalLevel;

  verbose = this.verbose;

  %
  % Preallocate some memory such that we do not need to reallocate
  % it at low levels. For high levels, we reallocate the memory
  % each time; however, since going from one high level to the
  % next one does not happen too often, we do not lose too much.
  %
  bufferSize = 200 * inputCount;

  levels = zeros(bufferSize, inputCount);
  orders = zeros(bufferSize, inputCount);

  surpluses = zeros(bufferSize, outputCount);

  newBufferSize = 100 * 2 * inputCount;

  newLevels = zeros(newBufferSize, inputCount);
  newOrders = zeros(newBufferSize, inputCount);

  function resizeBuffers(neededCount)
    addition = neededCount - bufferSize;

    if addition <= 0, return; end

    levels = [ levels; zeros(addition, inputCount) ];
    orders = [ orders; zeros(addition, inputCount) ];

    surpluses = [ surpluses; zeros(addition, outputCount) ];

    bufferSize = bufferSize + addition;
  end

  function resizeNewBuffers(neededCount)
    addition = neededCount - newBufferSize;

    if addition <= 0, return; end

    newLevels = [ newLevels; zeros(addition, inputCount) ];
    newOrders = [ newOrders; zeros(addition, inputCount) ];

    newBufferSize = newBufferSize + addition;
  end

  %
  % Level 1
  %
  J = tensor(basis.computeLevelOrders(1), inputCount);

  nodeCount = size(J, 1);
  resizeBuffers(nodeCount);

  levelNodeCount = zeros(maximalLevel, 1);
  levelNodeCount(1) = nodeCount;

  levels(1:nodeCount, :) = 1;
  orders(1:nodeCount, :) = J;

  passiveCount = 0;
  activeCount = nodeCount;

  level = 1;

  while true
    if verbose
      fprintf('Level %2d: passive %6d, active %6d, total %6d\n', ...
        level, passiveCount, activeCount, nodeCount);
    end

    activeRange = passiveCount + (1:activeCount);

    %
    % Evaluate the target function for the active nodes.
    %
    nodes = basis.computeNodes( ...
      levels(activeRange, :), orders(activeRange, :));
    values = f(nodes);

    %
    % Compute the surpluses of the active nodes.
    %
    if passiveCount == 0
      surpluses(activeRange, :) = values;
    else
      I = 1:passiveCount;
      base = basis.evaluate(levels(I, :), orders(I, :), nodes);
      for i = 1:activeCount
        surpluses(activeRange(i), :) = values(i, :) - ...
          sum(bsxfun(@times, surpluses(I, :), base(:, i)), 1);
      end
    end

    %
    % If the current level is the last one, we do not try to add any
    % more nodes; just exit the loop.
    %
    if level >= maximalLevel, break; end

    %
    % Adaptivity control
    %
    if level < minimalLevel
      nodeContribution = Inf(1, activeCount);
    else
      nodeContribution = max(abs(surpluses(activeRange, :)), [], 2);
    end

    %
    % Add the neighbors of those nodes that need to be refined.
    %
    newNodeCount = 0;
    for i = activeRange(nodeContribution > tolerance)
      for j = 1:inputCount
        childOrders = basis.computeChildOrders( ...
          levels(i, j), orders(i, j));

        childCount = length(childOrders);
        resizeNewBuffers(newNodeCount + childCount);

        for k = 1:childCount
          l = newNodeCount + k;

          newLevels(l, :) = levels(i, :);
          newLevels(l, j) = levels(i, j) + 1;

          newOrders(l, :) = orders(i, :);
          newOrders(l, j) = childOrders(k);
        end

        newNodeCount = newNodeCount + childCount;
      end
    end

    %
    % The new nodes have been identify, but they are not necessary unique.
    % Therefore, we need to filter out all duplicates.
    %
    [ ~, I ] = unique([ newLevels(1:newNodeCount, :), ...
      newOrders(1:newNodeCount, :) ], 'rows');

    newNodeCount = length(I);
    levelNodeCount(level) = newNodeCount;

    %
    % If there are no more nodes to refine, we stop.
    %
    if newNodeCount == 0, break; end

    range = nodeCount + (1:newNodeCount);

    nodeCount = nodeCount + newNodeCount;
    resizeBuffers(nodeCount);

    levels(range, :) = newLevels(I, :);
    orders(range, :) = newOrders(I, :);

    activeCount = newNodeCount;
    passiveCount = nodeCount - activeCount;

    level = level + 1;
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

  output.levels = levels(range, :);
  output.orders = orders(range, :);

  output.surpluses = surpluses(range, :);

  output.expectation = basis.computeExpectation( ...
    output.levels, output.orders, output.surpluses);

  output.variance = basis.computeVariance( ...
    output.levels, output.orders, output.surpluses);
end

function nodesND = tensor(nodes1D, dimensionCount)
  nodes1D = nodes1D(:);
  nodesND = nodes1D;
  a = ones(size(nodes1D, 1), 1);
  for i = 2:dimensionCount
    b = ones(size(nodesND, 1), 1);
    nodesND = [ kron(nodesND, a), kron(b, nodes1D) ];
  end
end
