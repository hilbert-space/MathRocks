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

  maximalIndexCount = intmax('uint16');
  maximalLevel = min(this.maximalLevel, intmax('uint8'));
  maximalNodeCount = this.maximalNodeCount;

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

  indexes = zeros(indexBufferSize, inputCount, 'uint8');
  forward = zeros(indexBufferSize, inputCount, 'uint16');
  backward = zeros(indexBufferSize, inputCount, 'uint16');
  errors = zeros(indexBufferSize, outputCount);
  active = false(indexBufferSize, 1);

  nodeBufferSize = 200 * inputCount;
  surpluses = zeros(nodeBufferSize, outputCount);
  mapping = zeros(nodeBufferSize, 1, 'uint16');

  %
  % Initialization
  %
  indexCount = 1;
  indexes(1, :) = 1;
  active(1) = true;

  newNodes = basis.computeNodes(indexes(1, :));
  assert(size(newNodes, 1) == 1);
  nodeCount = 1;

  surpluses(1, :) = f(newNodes);
  mapping(1) = 1;

  minimalValue = min(surpluses(1, :), [], 1);
  maximalValue = max(surpluses(1, :), [], 1);

  newBackward = zeros(inputCount, inputCount);

  while true
    I = find(active);

    verbose('level %2d, total indexes %6d, active indexes %6d, nodes %6d.\n', ...
      max(indexes(:)), indexCount, numel(I), nodeCount);

    globalError = max(abs(surpluses( ...
      ismember(mapping(1:nodeCount), I), :)), [], 1);

    if all(globalError < max(absoluteTolerance, ...
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
      [ mn, i ] = min(sum(indexes(I, :), 2));
      mx = max(sum(indexes(1:indexCount, :), 2));
      if mn > (1 - adaptivityDegree) * mx
        [ ~, i ] = max(sum(errors(I, :), 2));
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
    J = indexCount + (1:newIndexCount);

    %
    % Store the found indexes along with their backward and forward
    % neighborhoods; make the new indexes active.
    %
    indexes(J, :) = repmat(current, newIndexCount, 1);
    for i = 1:newIndexCount
      indexes(J(i), I(i)) = current(I(i)) + 1;
      forward(newBackward(I(i), newBackward(I(i), :) > 0), I(i)) = J(i);
    end
    backward(J, :) = newBackward(I, :);
    active(J) = true;

    %
    % Compute the nodes of the new indexes.
    %
    [ newNodes, newMapping ] = basis.computeNodes(indexes(J, :));
    newNodeCount = size(newNodes, 1);

    if nodeCount + newNodeCount > maximalNodeCount
      verbose('The maximal number of nodes has been reached.\n');
      break;
    end

    resizeNodeBuffers(nodeCount + newNodeCount);
    I = nodeCount + (1:newNodeCount);

    %
    % Compute the surpluses of the new nodes.
    %
    surpluses(I, :) = f(newNodes);
    mapping(I, :) = newMapping + indexCount;

    minimalValue = min([ minimalValue; min(surpluses(I, :), [], 1) ], [], 1);
    maximalValue = max([ maximalValue; max(surpluses(I, :), [], 1) ], [], 1);

    for i = 1:newIndexCount
      j = indexCount + i;
      I = find(newMapping == i);
      J = I + nodeCount;
      K = find(sum(bsxfun(@minus, indexes(1:indexCount, :), indexes(j, :)), 2) == 0);
      surpluses(J, :) = surpluses(J, :) - basis.evaluate(newNodes(I, :), ...
        indexes(K, :), surpluses(ismember(mapping(1:nodeCount), K), :));
      errors(j, :) = sum(abs(surpluses(J, :)), 1) / length(I);
    end

    indexCount = indexCount + newIndexCount;
    nodeCount = nodeCount + newNodeCount;
  end

  output.indexCount = indexCount;
  output.nodeCount = nodeCount;

  output.indexes = indexes(1:indexCount, :);
  output.surpluses = surpluses(1:nodeCount, :);
  output.mapping = mapping(1:nodeCount);

  output.expectation = zeros(1, outputCount);
  output.variance = zeros(1, outputCount);

  function resizeIndexBuffers(neededCount_)
    count_ = neededCount_ - indexBufferSize;

    if count_ <= 0, return; end
    count_ = min(maximalIndexCount, max(count_, indexBufferSize));

    indexes = [ indexes; zeros(count_, inputCount, 'uint8') ];
    forward = [ forward; zeros(count_, inputCount, 'uint16') ];
    backward = [ backward; zeros(count_, inputCount, 'uint16') ];
    errors = [ errors; zeros(count_, outputCount) ];
    active = [ active; false(count_, 1) ];

    indexBufferSize = indexBufferSize + count_;
    assert(indexBufferSize <= maximalIndexCount);
  end

  function resizeNodeBuffers(neededCount_)
    count_ = neededCount_ - nodeBufferSize;

    if count_ <= 0, return; end
    count_ = min(maximalNodeCount, max(count_, nodeBufferSize));

    surpluses = [ surpluses; zeros(count_, outputCount) ];
    mapping = [ mapping; zeros(count_, 1, 'uint16') ];

    nodeBufferSize = nodeBufferSize + count_;
  end
end
