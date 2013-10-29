function output = construct(this, f, outputCount)
  basis = this.basis;

  if this.verbose
    verbose = @(text, varargin) fprintf(text, varargin{:});
  else
    verbose = @(varargin) [];
  end

  inputCount = this.inputCount;
  if nargin < 3, outputCount = this.outputCount; end

  %
  % Adaptivity control
  %
  absoluteTolerance = this.absoluteTolerance;
  relativeTolerance = this.relativeTolerance;

  maximalNodeCount = this.maximalNodeCount;

  minimalLevel = this.minimalLevel;
  maximalLevel = basis.maximalLevel;

  minimalValue = Inf(1, outputCount);
  maximalValue = -Inf(1, outputCount);

  %
  % Preallocate some memory such that we do not need to reallocate
  % it at low levels. For high levels, we reallocate the memory
  % each time; however, since going from one high level to the
  % next one does not happen too often, we do not lose too much.
  %
  bufferSize = 200 * inputCount;

  levels = zeros(bufferSize, inputCount, 'uint8');
  orders = zeros(bufferSize, inputCount, 'uint32');

  surpluses = zeros(bufferSize, outputCount);

  %
  % Prepare the first level.
  %
  J = Utils.tensor(repmat({ basis.computeLevelOrders(1) }, inputCount, 1));

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

    verbose('Level %2d, passive %6d, active %6d, total %6d\n', ...
      level, passiveCount, activeCount, nodeCount);

    if nodeCount >= maximalNodeCount
      verbose('The maximal number of nodes has been reached.\n');
      break;
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
      [ uniqueLevels, ~, I ] = unique(levels(activeRange, :), 'rows');
      for i = 1:size(uniqueLevels, 1)
        J = I == i;
        K = sum(bsxfun(@minus, levels(passiveRange, :), ...
          uniqueLevels(i, :)), 2) == 0;
        surpluses(activeRange(J), :) = values(J, :) - basis.evaluate( ...
          nodes(J, :), levels(passiveRange(K), :), orders(passiveRange(K), :), ...
          surpluses(passiveRange(K), :));
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

  function resizeBuffers(neededCount_)
    count_ = neededCount_ - bufferSize;

    if count_ <= 0, return; end
    count_ = max(count_, bufferSize);

    levels = [ levels; zeros(count_, inputCount, 'uint8') ];
    orders = [ orders; zeros(count_, inputCount, 'uint32') ];

    surpluses = [ surpluses; zeros(count_, outputCount) ];

    bufferSize = bufferSize + count_;
  end
end
