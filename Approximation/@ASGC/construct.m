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
  nodes  = zeros(bufferSize, inputCount);

  values    = zeros(bufferSize, outputCount);
  surpluses = zeros(bufferSize, outputCount);

  newBufferSize = 100 * 2 * inputCount;

  newLevels = zeros(newBufferSize, inputCount);
  newOrders = zeros(newBufferSize, inputCount);
  newNodes  = zeros(newBufferSize, inputCount);

  function resizeBuffers(neededCount)
    addition = neededCount - bufferSize;

    if addition <= 0, return; end

    levels = [ levels; zeros(addition, inputCount) ];
    orders = [ orders; zeros(addition, inputCount) ];
    nodes  = [ nodes;  zeros(addition, inputCount) ];

    values    = [ values;    zeros(addition, outputCount) ];
    surpluses = [ surpluses; zeros(addition, outputCount) ];

    bufferSize = bufferSize + addition;
  end

  function resizeNewBuffers(neededCount)
    addition = neededCount - newBufferSize;

    if addition <= 0, return; end

    newLevels = [ newLevels; zeros(addition, inputCount) ];
    newOrders = [ newOrders; zeros(addition, inputCount) ];
    newNodes  = [ newNodes;  zeros(addition, inputCount) ];

    newBufferSize = newBufferSize + addition;
  end

  levelNodeCount = zeros(maximalLevel, 1);

  %
  % Level 1
  %
  [ Y, J ] = basis.computeNodes(1);
  J = tensor(J, inputCount);
  Y = tensor(Y, inputCount);

  nodeCount = size(Y, 1);
  resizeBuffers(nodeCount);

  levels(1:nodeCount, :) = 1;
  orders(1:nodeCount, :) = J;
  nodes (1:nodeCount, :) = Y;

  levelNodeCount(1) = nodeCount;
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
    values(activeRange, :) = f(nodes(activeRange, :));

    %
    % Compute the surpluses of the active nodes.
    %
    if passiveCount == 0
      surpluses(activeRange, :) = values(activeRange, :);
    else
      passiveLevels = levels(1:passiveCount, :);
      intervals = 2.^(passiveLevels - 1) + 1;
      inversed = 1 ./ (intervals - 1);

      delta = zeros(passiveCount, inputCount);
      for i = activeRange
        for j = 1:inputCount
          delta(:, j) = abs(nodes(1:passiveCount, j) - nodes(i, j));
        end
        I = find(all(delta < inversed, 2));

        bases = 1 - (intervals(I, :) - 1) .* delta(I, :);
        bases(passiveLevels(I, :) == 1) = 1;
        bases = prod(bases, 2);

        surpluses(i, :) = values(i, :) - ...
          sum(bsxfun(@times, surpluses(I, :), bases), 1);
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
        [ childNodes, childOrders ] = basis.computeChildNodes( ...
          levels(i, j), orders(i, j));

        childCount = length(childOrders);
        resizeNewBuffers(newNodeCount + childCount);

        for k = 1:childCount
          l = newNodeCount + k;

          newLevels(l, :) = levels(i, :);
          newLevels(l, j) = levels(i, j) + 1;

          newOrders(l, :) = orders(i, :);
          newOrders(l, j) = childOrders(k);

          newNodes(l, :) = nodes(i, :);
          newNodes(l, j) = childNodes(k);
        end

        newNodeCount = newNodeCount + childCount;
      end
    end

    %
    % The new nodes have been identify, but they are not necessary unique.
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

    range = nodeCount + (1:newNodeCount);

    nodeCount = nodeCount + newNodeCount;
    resizeBuffers(nodeCount);

    activeCount = newNodeCount;
    passiveCount = nodeCount - activeCount;

    levels(range, :) = uniqueNewLevels;
    orders(range, :) = uniqueNewOrders;
    nodes (range, :) = uniqueNewNodes;

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

  output.expectation = zeros(1, outputCount);
  output.variance = zeros(1, outputCount);
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
