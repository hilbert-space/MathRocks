function output = construct(this, f, outputCount)
  zeros = @uninit;

  basis = this.basis;

  inputCount = this.inputCount;
  if nargin < 3, outputCount = this.outputCount; end

  absoluteTolerance = this.absoluteTolerance;
  relativeTolerance = this.relativeTolerance;

  minimalLevel = this.minimalLevel;
  maximalLevel = this.maximalLevel;

  verbose = this.verbose;

  %
  % Adaptivity control
  %
  minimalValue = Inf(1, outputCount);
  maximalValue = -Inf(1, outputCount);

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

  %
  % Prepare the first level.
  %
  J = tensor(basis.computeLevelOrders(1), inputCount);

  nodeCount = size(J, 1);
  resizeBuffers(nodeCount);

  levels(1:nodeCount, :) = 1;
  orders(1:nodeCount, :) = J;

  level = 0;
  passiveCount = 0;
  activeCount = nodeCount;

  levelNodeCount = zeros(maximalLevel, 1);

  while activeCount > 0
    level = level + 1;
    levelNodeCount(level) = activeCount;

    if verbose
      fprintf('Level %2d: passive %6d, active %6d, total %6d\n', ...
        level, passiveCount, activeCount, nodeCount);
    end

    passiveRange = 1:passiveCount;
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
      surpluses(activeRange, :) = values - basis.evaluate( ...
        nodes, levels(passiveRange, :), orders(passiveRange, :), ...
        surpluses(passiveRange, :));
    end

    %
    % If the current level is the last one, we do not try to add any
    % more nodes; just exit the loop.
    %
    if level >= maximalLevel, break; end

    %
    % Adaptivity control
    %
    minimalValue = min([ minimalValue; min(values, [], 1) ], [], 1);
    maximalValue = max([ maximalValue; max(values, [], 1) ], [], 1);

    if level < minimalLevel
      refineRange = activeRange;
    else
      absoluteError = abs(surpluses(activeRange, :));
      refineRange = activeRange( ...
        max(absoluteError, [], 2) > absoluteTolerance | ...
        max(bsxfun(@rdivide, absoluteError, ...
          maximalValue - minimalValue), [], 2) > relativeTolerance);
    end

    %
    % Add the child nodes of those nodes that need to be refined.
    %
    [ childLevels, childOrders ] = basis.computeChildren( ...
      levels(refineRange, :), orders(refineRange, :));

    %
    % The child nodes become the new active nodes.
    %
    activeCount = size(childLevels, 1);
    activeRange = nodeCount + (1:activeCount);

    %
    % The total number of nodes increases, and the buffers
    % should be enlarged if needed.
    %
    nodeCount = nodeCount + activeCount;
    resizeBuffers(nodeCount);

    levels(activeRange, :) = childLevels;
    orders(activeRange, :) = childOrders;

    passiveCount = nodeCount - activeCount;
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

  function resizeBuffers(neededCount_)
    count_ = neededCount_ - bufferSize;

    if count_ <= 0, return; end
    count_ = max(count_, bufferSize);

    levels = [ levels; zeros(count_, inputCount) ];
    orders = [ orders; zeros(count_, inputCount) ];

    surpluses = [ surpluses; zeros(count_, outputCount) ];

    bufferSize = bufferSize + count_;
  end
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
