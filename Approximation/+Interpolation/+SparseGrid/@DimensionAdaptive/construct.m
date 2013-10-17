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

  globalError = Inf(1, outputCount);

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
  level = ones(1, inputCount, 'uint8');
  indexCount = 1;
  index(1, :) = 1;
  active(1) = true;

  newNodes = basis.computeNodes(index(1, :));
  nodeCount = size(newNodes, 1);
  resizeNodeBuffers(nodeCount);

  surpluses(1:nodeCount) = f(newNodes);
  mapping(1:nodeCount) = 1;

  while true
    verbose('level %2d, total indexes %6d, active indexes %6d, nodes %6d.\n', ...
      max(level), indexCount, nnz(active), nodeCount);

    if nodeCount >= maximalNodeCount
      verbose('The maximal number of nodes has been reached.\n');
      break;
    end

    if all(globalError < max(absoluteTolerance, ...
      relativeTolerance * (maximalValue - minimalValue)))
      verbose('The desired level of accuracy has been reached.');
      break;
    end

    %
    % Find the next active index and turn it into a passive one.
    %
    I = find(active);

    switch numel(I)
    case 0
      verbose('There are no active indexes to refine.');
      break;
    case 1
      R = I;
    otherwise
      [ total, i ] = min(sum(index(I, :), 2));
      if total > (1 - adaptivityDegree) * max(sum(index(1:indexCount, :), 2))
        [ ~, i ] = max(sum(error(I, :), 2));
      end
      R = I(i);
    end

    active(R) = false;
    passive(R) = true;

    %
    % Find admissible neighbors of the index being refined.
    %
    newIndex = repmat(index(R, :), inputCount, 1) + eye(inputCount, 'uint8');

    I = true(inputCount, 1);
    for i = 1:inputCount
      if any(newIndex(i, :) > maximalLevel)
        I(i) = false;
        continue;
      end

      if ismember(newIndex(i, :), index(1:indexCount, :), 'rows')
        I(i) = false;
        continue;
      end

      backwardIndex = repmat(newIndex(i, :), ...
        inputCount, 1) - eye(inputCount, 'uint8');
      for j = 1:inputCount
        if i == j, continue; end
        if nnz(backwardIndex(j, :)) > 0, continue; end
        if ~ismember(backwardIndex(j, :), index(passive, :), 'rows')
          I(i) = false;
          break;
        end
      end
    end

    newIndex = newIndex(I, :);
    newIndexCount = size(newIndex, 1);

    if newIndexCount == 0
      verbose('There are no admissible nodes.\n');
      continue;
    end

    %
    % Compute the nodes of each new index.
    %
    [ newNodes, newMapping ] = basis.computeNodes(newIndex);
    newValues = basis.evaluate(newNodes, ...
      index(1:indexCount, :), surpluses(1:nodeCount, :));
    newMapping = newMapping + indexCount;
    newNodeCount = size(newNodes, 1);

    %
    % Store the new indexes and make them active.
    %
    I = indexCount + (1:newIndexCount);
    indexCount = indexCount + newIndexCount;
    resizeIndexBuffers(indexCount);

    index(I, :) = newIndex;
    active(I) = true;

    %
    % Compute and store the corresponding surpluses.
    %
    I = nodeCount + (1:newNodeCount);
    nodeCount = nodeCount + newNodeCount;
    resizeNodeBuffers(nodeCount);

    values = f(newNodes);
    surpluses(I, :) = values - newValues;
    mapping(I) = newMapping;

    %
    % Compute the interpolation error of the index that has
    % just been refined and the global error.
    %
    error(R, :) = sum(abs(surpluses(I, :)), 1) / newNodeCount;

    globalError = max(abs(surpluses(ismember(mapping(1:nodeCount), ...
      find(active)), :)), [], 1);

    %
    % Update other statistics.
    %
    minimalValue = min([ minimalValue; min(values, [], 1) ], [], 1);
    maximalValue = max([ maximalValue; max(values, [], 1) ], [], 1);

    level = max([ level; max(newIndex, [], 1) ], [], 1);
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
