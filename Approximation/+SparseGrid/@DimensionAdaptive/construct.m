function output = construct(this, f, outputCount)
  basis = this.basis;

  if this.verbose
    verbose = @(text, varargin) ...
      fprintf([ 'SparseGrid: ', text ], varargin{:});
  else
    verbose = @(varargin) [];
  end

  inputCount = this.inputCount;
  if nargin < 3, outputCount = this.outputCount; end

  maximalLevel = min(intmax('uint8'), this.maximalLevel);
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
  counts = zeros(indexBufferSize, 1, 'uint32');

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

  basis.ensureLevel(level);

  surpluses(1, :) = f(basis.computeNodes(indexes(1, :)));
  offsets(1) = 0;
  counts(1) = 1;

  scores(1, 2) = sum(abs(surpluses(1, :)));
  errors(1, :) = abs(surpluses(1, :));

  minimalValue = surpluses(1, :);
  maximalValue = surpluses(1, :);

  newBackward = zeros(inputCount, inputCount, 'uint16');

  while true
    I = find(active);

    verbose('level %2d, total indexes %6d, active indexes %6d, nodes %6d.\n', ...
      level, indexCount, numel(I), nodeCount);

    if all(max(errors(I, :), [], 1) < max(absoluteTolerance, ...
      relativeTolerance * (maximalValue - minimalValue)))

      verbose('The desired level of accuracy has been reached.\n');
      break;
    end

    %
    % Find the next active index to refine.
    %
    switch numel(I)
    case 0
      verbose('There are no active indexes to refine.\n');
      break;
    case 1
      C = I;
    otherwise
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
      forward(newBackward(I(i), newBackward(I(i), :) > 0), I(i)) = J(i);
    end
    backward(J, :) = newBackward(I, :);

    active(J) = true;
    scores(J, 1) = sum(indexes(J, :), 2);

    %
    % Compute the nodes of the new indexes.
    %
    basis.ensureLevel(level);
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
    counts(J) = newCounts;

    minimalValue = min([ minimalValue; ...
      min(surpluses(I, :), [], 1) ], [], 1);
    maximalValue = max([ maximalValue; ...
      max(surpluses(I, :), [], 1) ], [], 1);

    for j = J
      I = (offsets(j) + 1):(offsets(j) + counts(j));
      K = find(sum(bsxfun(@minus, ...
        indexes(1:indexCount, :), indexes(j, :)), 2) == 0);

      surpluses(I, :) = surpluses(I, :) - basis.evaluate(newNodes(I - nodeCount, :), ...
        indexes(K, :), surpluses(constructNodeIndex(K), :));

      scores(j, 2) = sum(sum(abs(surpluses(I, :)), 1) / counts(j));
      errors(j, :) = max(abs(surpluses(I, :)), [], 1);
    end

    indexCount = indexCount + newIndexCount;
    nodeCount = nodeCount + newNodeCount;
  end

  output.indexCount = indexCount;
  output.nodeCount = nodeCount;

  output.indexes = indexes(1:indexCount, :);

  output.surpluses = surpluses(1:nodeCount, :);
  output.offsets = offsets(1:indexCount);
  output.counts = counts(1:indexCount);

  function I_ = constructNodeIndex(K_)
    I_ = zeros(sum(counts(K_)), 1, 'uint32');
    shift_ = 0;
    for i_ = 1:length(K_)
      k_ = K_(i_);
      I_((shift_ + 1):(shift_ + counts(k_))) = ...
        (offsets(k_) + 1):(offsets(k_) + counts(k_));
      shift_ = shift_ + counts(k_);
    end
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
    counts = [ counts; zeros(count_, 1, 'uint32') ];

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
