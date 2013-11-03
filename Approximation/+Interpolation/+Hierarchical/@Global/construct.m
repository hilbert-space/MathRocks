function output = construct(this, f, outputCount)
  basis = this.basis;

  if this.verbose
    verbose = @(text, varargin) fprintf(text, varargin{:});
  else
    verbose = @(varargin) [];
  end

  inputCount = this.inputCount;
  if nargin < 3, outputCount = this.outputCount; end

  maximalLevel = min(intmax('uint8'), basis.maximalLevel);
  maximalIndexCount = intmax('uint16');
  maximalNodeCount = min(intmax('uint32'), this.maximalNodeCount);

  %
  % Adaptivity control
  %
  absoluteTolerance = this.absoluteTolerance;
  relativeTolerance = this.relativeTolerance;

  adaptivityDegree = this.adaptivityDegree;

  %
  % Memory preallocation
  %
  indexBufferSize = 200 * inputCount;
  nodeBufferSize = 200 * inputCount;

  indexes = zeros(indexBufferSize, inputCount, 'uint8');
  active = false(indexBufferSize, 1);
  scores = zeros(indexBufferSize, 2);

  forward = zeros(indexBufferSize, inputCount, 'uint16');
  backward = zeros(indexBufferSize, inputCount, 'uint16');

  surpluses = zeros(nodeBufferSize, outputCount);
  offsets = zeros(indexBufferSize, 1, 'uint32');

  errors = zeros(indexBufferSize, outputCount);

  %
  % Initialization
  %
  level = 1;

  indexCount = 1;
  nodeCount = 1;

  indexes(1, :) = 1;
  active(1) = true;
  scores(1, 1) = sum(indexes(1, :));

  surpluses(1, :) = f(basis.computeNodes(indexes(1, :)));
  offsets(1) = 0;

  scores(1, 2) = sum(abs(surpluses(1, :)));
  errors(1, :) = abs(surpluses(1, :));

  minimalValue = surpluses(1, :);
  maximalValue = surpluses(1, :);

  newBackward = zeros(inputCount, inputCount, 'uint16');

  while true
    I = find(active);
    activeIndexCount = numel(I);

    verbose('Level %2d, total indexes %6d, active indexes %6d, nodes %6d.\n', ...
      level, indexCount, activeIndexCount, nodeCount);

    if activeIndexCount == 0
      verbose('There are no active indexes to refine.\n');
      break;
    end

    if all(max(errors(I, :), [], 1) < max(absoluteTolerance, ...
      relativeTolerance * (maximalValue - minimalValue)))

      verbose('The desired level of accuracy has been reached.\n');
      break;
    end

    %
    % Find the next active index to refine.
    %
    if activeIndexCount == 1
      C = I;
    else
      [ minimalSum, i ] = min(scores(I, 1));
      maximalSum = max(scores(1:indexCount, 1));
      if minimalSum > (1 - adaptivityDegree) * maximalSum
        [ ~, i ] = max(scores(I, 2));
      end
      C = I(i);
    end

    active(C) = false;
    current = indexes(C, :);

    %
    % Find admissible forward indexes of the current index.
    %
    I = true(1, inputCount);
    J = find(current > 1);

    newBackward(:) = 0;
    for i = 1:inputCount
      if current(i) + 1 > maximalLevel
        I(i) = false;
        continue;
      end
      newBackward(i, i) = C;
      for j = J
        if i == j, continue; end
        newBackward(i, j) = forward(backward(C, j), i);
        if newBackward(i, j) == 0 || active(newBackward(i, j))
          I(i) = false;
          break;
        end
      end
    end

    I = find(I);
    newIndexCount = length(I);

    if newIndexCount == 0
      verbose('There are no admissible nodes of the current active index.\n');
      continue;
    elseif indexCount + newIndexCount > maximalIndexCount
      verbose('The maximal number of indexes has been reached.\n');
      break;
    end

    resizeIndexBuffers(indexCount + newIndexCount);
    J = (indexCount + 1):(indexCount + newIndexCount);

    %
    % Store the found indexes along with their backward and forward
    % neighborhoods; make the new indexes active.
    %
    indexes(J, :) = repmat(current, newIndexCount, 1);
    for i = 1:newIndexCount
      newLevel = current(I(i)) + 1;
      level = max(level, newLevel);

      indexes(J(i), I(i)) = newLevel;

      for j = find(newBackward(I(i), :) > 0)
        forward(newBackward(I(i), j), j) = J(i);
      end
    end
    backward(J, :) = newBackward(I, :);

    active(J) = true;
    scores(J, 1) = sum(indexes(J, :), 2);

    %
    % Compute the nodes of the new indexes.
    %
    [ newNodes, newOffsets, newCounts ] = basis.computeNodes(indexes(J, :));
    newNodeCount = size(newNodes, 1);

    if nodeCount + newNodeCount > maximalNodeCount
      verbose('The maximal number of nodes has been reached.\n');
      break;
    end

    resizeNodeBuffers(nodeCount + newNodeCount);
    I = (nodeCount + 1):(nodeCount + newNodeCount);

    %
    % Compute the surpluses of the new nodes.
    %
    surpluses(I, :) = f(newNodes);
    offsets(J) = nodeCount + newOffsets;

    minimalValue = min([ minimalValue; ...
      min(surpluses(I, :), [], 1) ], [], 1);
    maximalValue = max([ maximalValue; ...
      max(surpluses(I, :), [], 1) ], [], 1);

    for i = 1:newIndexCount
      I = (nodeCount + newOffsets(i) + 1): ...
        (nodeCount + newOffsets(i) + newCounts(i));

      surpluses(I, :) = surpluses(I, :) - basis.evaluate( ...
        newNodes(I - nodeCount, :), indexes, surpluses, offsets, ...
        findInferiorIndexes(indexes(J(i), :)));

      scores(J(i), 2) = sum(sum(abs(surpluses(I, :)), 1) / double(newCounts(i)));
      errors(J(i), :) = max(abs(surpluses(I, :)), [], 1);
    end

    indexCount = indexCount + newIndexCount;
    nodeCount = nodeCount + newNodeCount;
  end

  output = struct;

  output.outputCount = outputCount;

  output.indexCount = indexCount;
  output.nodeCount = nodeCount;

  output.indexes = indexes(1:indexCount, :);
  output.surpluses = surpluses(1:nodeCount, :);
  output.offsets = offsets(1:indexCount);

  function I_ = findInferiorIndexes(index_)
    I_ = find(sum(bsxfun(@minus, ...
      indexes(1:indexCount, :), index_), 2) == 0).';
  end

  function resizeIndexBuffers(neededCount_)
    count_ = neededCount_ - indexBufferSize;

    if count_ <= 0, return; end
    count_ = min(maximalIndexCount, max(count_, indexBufferSize));

    indexes = [ indexes; zeros(count_, inputCount, 'uint8') ];
    forward = [ forward; zeros(count_, inputCount, 'uint16') ];
    backward = [ backward; zeros(count_, inputCount, 'uint16') ];

    active = [ active; false(count_, 1) ];
    scores = [ scores; zeros(count_, 1) ];

    offsets = [ offsets; zeros(count_, 1, 'uint32') ];

    errors = [ errors; zeros(count_, outputCount) ];

    indexBufferSize = indexBufferSize + count_;
  end

  function resizeNodeBuffers(neededCount_)
    count_ = neededCount_ - nodeBufferSize;

    if count_ <= 0, return; end
    count_ = min(maximalNodeCount, max(count_, nodeBufferSize));

    surpluses = [ surpluses; zeros(count_, outputCount) ];

    nodeBufferSize = nodeBufferSize + count_;
  end
end
