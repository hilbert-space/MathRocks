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

  %
  % Adaptivity control
  %
  absoluteTolerance = this.absoluteTolerance;
  relativeTolerance = this.relativeTolerance;

  maximalNodeCount = this.maximalNodeCount;

  maximalLevel = this.maximalLevel;

  adaptivityDegree = this.adaptivityDegree;

  minimalValue = Inf(1, outputCount);
  maximalValue = -Inf(1, outputCount);

  %
  % Memory preallocation
  %
  indexBufferSize = 200 * inputCount;

  index = zeros(indexBufferSize, inputCount, 'uint8');
  error = zeros(indexBufferSize, outputCount);
  active = false(indexBufferSize, 1);
  passive = false(indexBufferSize, 1);

  nodeBufferSize = 200 * inputCount;
  surpluses = zeros(nodeBufferSize, outputCount);
  mapping = zeros(nodeBufferSize, 1, 'uint32');

  %
  % Initialization
  %
  indexCount = 1;
  index(1, :) = 1;
  active(1) = true;

  newNodes = basis.computeNodes(index(1, :));
  nodeCount = size(newNodes, 1);
  resizeNodeBuffers(nodeCount);

  newValues = f(newNodes);
  surpluses(1:nodeCount) = newValues;
  mapping(1:nodeCount) = 1;

  while true
    I = find(active);

    verbose('level %2d, total indexes %6d, active indexes %6d, nodes %6d.\n', ...
      max(index(:)), indexCount, numel(I), nodeCount);

    if nodeCount >= maximalNodeCount
      verbose('The maximal number of nodes has been reached.\n');
      break;
    end

    minimalValue = min([ minimalValue; min(newValues, [], 1) ], [], 1);
    maximalValue = max([ maximalValue; max(newValues, [], 1) ], [], 1);

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
    otherwise
      [ mn, i ] = min(sum(index(I, :), 2));
      mx = max(sum(index(1:indexCount, :), 2));
      if mn > (1 - adaptivityDegree) * mx 
        [ ~, i ] = max(sum(error(I, :), 2));
      end
      I = I(i);
    end

    %
    % Move the index from the set of active indexes
    % to the set of passive ones.
    %
    active(I) = false;
    passive(I) = true;

    %
    % Find admissible neighbors of the current active index.
    %
    newIndex = repmat(index(I, :), inputCount, 1) + eye(inputCount, 'uint8');

    I = true(inputCount, 1);
    for i = 1:inputCount
      forward = newIndex(i, :);

      if any(forward > maximalLevel)
        I(i) = false;
        continue;
      end

      if ismember(forward, index(1:indexCount, :), 'rows')
        I(i) = false;
        continue;
      end

      for j = find(forward > 1)
        if i == j, continue; end
        backward = forward;
        backward(j) = backward(j) - 1;
        if ~ismember(backward, index(passive, :), 'rows')
          I(i) = false;
          break;
        end
      end
    end

    newIndex = newIndex(I, :);

    newIndexCount = size(newIndex, 1);
    resizeIndexBuffers(indexCount + newIndexCount);

    if newIndexCount == 0
      verbose('There are no admissible nodes.\n');
      continue;
    end

    %
    % Store the new indexes and make them active.
    %
    I = indexCount + (1:newIndexCount);
    index(I, :) = newIndex;
    active(I) = true;

    %
    % Compute the nodes and function values for the new indexes.
    %
    [ newNodes, newMapping ] = basis.computeNodes(newIndex);
    newValues = f(newNodes);

    newNodeCount = size(newNodes, 1);
    resizeNodeBuffers(nodeCount + newNodeCount);

    %
    % Compute and store the corresponding surpluses along with
    % the interpolation error for each new index.
    %
    for i = 1:newIndexCount
      I = find(newMapping == i);
      J = I + nodeCount;
      K = find(sum(bsxfun(@minus, index(1:indexCount, :), newIndex(i, :)), 2) == 0);

      surpluses(J, :) = newValues(I, :) - basis.evaluate(newNodes(I, :), ...
        index(K, :), surpluses(ismember(mapping(1:nodeCount), K), :));
      mapping(J) = indexCount + i;
      error(indexCount + i, :) = sum(abs(surpluses(J, :)), 1) / nnz(I);
    end

    indexCount = indexCount + newIndexCount;
    nodeCount = nodeCount + newNodeCount;
  end

  output.indexCount = indexCount;
  output.nodeCount = nodeCount;

  output.index = index(1:indexCount, :);
  output.surpluses = surpluses(1:nodeCount, :);
  output.mapping = mapping(1:nodeCount);

  output.expectation = zeros(1, outputCount);
  output.variance = zeros(1, outputCount);

  function resizeIndexBuffers(neededCount_)
    count_ = neededCount_ - indexBufferSize;

    if count_ <= 0, return; end
    count_ = max(count_, indexBufferSize);

    index = [ index; zeros(count_, inputCount, 'uint8') ];
    error = [ error; zeros(count_, outputCount) ];
    active = [ active; false(count_, 1) ];
    passive = [ passive; false(count_, 1) ];

    indexBufferSize = indexBufferSize + count_;
  end

  function resizeNodeBuffers(neededCount_)
    count_ = neededCount_ - nodeBufferSize;

    if count_ <= 0, return; end
    count_ = max(count_, nodeBufferSize);

    surpluses = [ surpluses; zeros(count_, outputCount) ];
    mapping = [ mapping; zeros(count_, 1, 'uint32') ];

    nodeBufferSize = nodeBufferSize + count_;
  end
end
