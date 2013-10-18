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

  %
  % Memory preallocation
  %
  indexBufferSize = 200 * inputCount;

  indexes = zeros(indexBufferSize, inputCount, 'uint8');
  errors = zeros(indexBufferSize, outputCount);
  active = false(indexBufferSize, 1);

  nodeBufferSize = 200 * inputCount;
  surpluses = zeros(nodeBufferSize, outputCount);
  mapping = zeros(nodeBufferSize, 1, 'uint32');

  %
  % Initialization
  %
  indexCount = 1;
  indexes(1, :) = 1;
  active(1) = true;

  newNodes = basis.computeNodes(indexes(1, :));
  nodeCount = size(newNodes, 1);
  resizeNodeBuffers(nodeCount);

  surpluses(1:nodeCount) = f(newNodes);
  mapping(1:nodeCount) = 1;

  minimalValue = min(surpluses(1:nodeCount, :), [], 1);
  maximalValue = max(surpluses(1:nodeCount, :), [], 1);

  while true
    I = find(active);

    verbose('level %2d, total indexes %6d, active indexes %6d, nodes %6d.\n', ...
      max(indexes(:)), indexCount, numel(I), nodeCount);

    if nodeCount >= maximalNodeCount
      verbose('The maximal number of nodes has been reached.\n');
      break;
    end

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
      [ mn, i ] = min(sum(indexes(I, :), 2));
      mx = max(sum(indexes(1:indexCount, :), 2));
      if mn > (1 - adaptivityDegree) * mx
        [ ~, i ] = max(sum(errors(I, :), 2));
      end
      I = I(i);
    end

    active(I) = false;
    current = indexes(I, :);

    %
    % Find admissible indexes in the forward neighborhood
    % of the current active index.
    %
    passiveIndex = indexes(~active(1:indexCount), :);

    I = true(1, inputCount);

    for i = 1:inputCount
      if current(i) + 1 > maximalLevel
        I(i) = false;
        continue;
      end
      forward = current;
      forward(i) = forward(i) + 1;
      for j = find(forward > 1)
        if i == j, continue; end
        backward = forward;
        backward(j) = backward(j) - 1;
        if ~ismember(backward, passiveIndex, 'rows')
          I(i) = false;
          break;
        end
      end
    end

    I = find(I);
    newIndexCount = length(I);
    resizeIndexBuffers(indexCount + newIndexCount);

    if newIndexCount == 0
      verbose('There are no admissible nodes.\n');
      continue;
    end

    %
    % Store the new indexes and make them active.
    %
    J = indexCount + (1:newIndexCount);

    indexes(J, :) = replicate(current, newIndexCount, I, 1);
    active(J) = true;

    %
    % Compute the nodes of the new indexes.
    %
    [ newNodes, newMapping ] = basis.computeNodes(indexes(J, :));
    newNodeCount = size(newNodes, 1);
    resizeNodeBuffers(nodeCount + newNodeCount);

    I = nodeCount + (1:newNodeCount);

    surpluses(I, :) = f(newNodes);
    mapping(I, :) = newMapping + indexCount;

    minimalValue = min([ minimalValue; min(surpluses(I, :), [], 1) ], [], 1);
    maximalValue = max([ maximalValue; max(surpluses(I, :), [], 1) ], [], 1);

    %
    % Compute and store the corresponding surpluses along with
    % the interpolation error for each new index.
    %
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

  %
  % Double-checking the algorithm.
  %
  indexCount = size(unique(output.indexes, 'rows'), 1);
  if indexCount ~= output.indexCount
    warning('There are %d duplicate indexes.', output.indexCount - indexCount);
  end

  function resizeIndexBuffers(neededCount_)
    count_ = neededCount_ - indexBufferSize;

    if count_ <= 0, return; end
    count_ = max(count_, indexBufferSize);

    indexes = [ indexes; zeros(count_, inputCount, 'uint8') ];
    errors = [ errors; zeros(count_, outputCount) ];
    active = [ active; false(count_, 1) ];

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

  function result_ = replicate(etalon_, count_, alter_, change_)
    result_ = repmat(etalon_, count_, 1);
    for i_ = 1:count_
      result_(i_, alter_(i_)) = etalon_(alter_(i_)) + change_;
    end
  end
end
