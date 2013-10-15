function output = construct(this, f, outputCount)
  if this.verbose;
    verbose = @(text, varargin) ...
      fprintf([ 'Interpolation: ', text ], varargin{:});
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

  newNodes = computeNodes(index(1, :));
  nodeCount = size(newNodes, 1);
  resizeNodeBuffers(nodeCount);

  surpluses(1:nodeCount) = f(newNodes);
  mapping(1:nodeCount) = 1;

  while true
    verbose('level %d, passive %d, active %d, nodes %d.\n', ...
      max(level), nnz(passive), nnz(active), nodeCount);

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
    newIndex = repmat(index(R, :), inputCount, 1) + eye(inputCount);

    passiveIndex = index(passive, :);
    I = true(inputCount, 1);
    for i = 1:inputCount
      if any(newIndex(i, :) > maximalLevel)
        %
        % The maximal level has been reached.
        %
        I(i) = false;
        continue;
      end

      backwardIndex = repmat(newIndex(i, :), ...
        inputCount, 1) - eye(inputCount);
      for j = 1:inputCount
        if i == j, continue; end
        if isempty(find(ismember( ...
          passiveIndex, backwardIndex(j, :)), 1))
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
    [ newValues, newNodes, newMapping ] = evaluateBasis( ...
      newIndex, index(1:indexCount, :), surpluses(1:nodeCount, :));
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

  output.index = index(1:indexCount);
  output.surpluses = surpluses(1:nodeCount);
  output.mapping = mapping(1:nodeCount);

  function resizeIndexBuffers(neededCount_)
    count_ = neededCount_ - indexBufferSize;

    if count_ <= 0, return; end

    index = [ index; zeros(count_, inputCount, 'uint8') ];
    error = [ error; zeros(count_, outputCount) ];
    active = [ active; false(count_, 1) ];
    passive = [ passive; false(count_, 1) ];

    indexBufferSize = indexBufferSize + count_;
  end

  function resizeNodeBuffers(neededCount_)
    count_ = neededCount_ - nodeBufferSize;

    if count_ <= 0, return; end

    surpluses = [ surpluses; zeros(count, outputCount) ];
    mapping = [ mapping; zeros(count, 1, 'uint32') ];

    nodeBufferSize = nodeBufferSize + count_;
  end
end

function [ nodes, radius, dimension ] = configureHierarchicalLevel(i)
  switch i
  case 1
    nodes = 0.5;
    dimension = uint32(1);
    radius = 1;
  case 2
    nodes = [ 0; 1 ];
    dimension = uint32(3);
    radius = 0.5;
  otherwise
    assert(i <= 32);
    nodes = transpose((2 * (1:2^(double(i) - 2)) - 1) * 2^(-double(i )+ 1));
    dimension = uint32(2^(i - 1) + 1);
    radius = 1 ./ (double(dimension) - 1);
  end
end

function basis = configureHierarchicalBasis(levels)
  maximalLevel = max(levels);
  basis.nodes = cell(maximalLevel, 1);
  basis.ranges = zeros(maximalLevel, 1);
  basis.dimensions = zeros(maximalLevel, 1, 'uint32');
  basis.counts = zeros(maximalLevel, 1, 'uint32');
  for i = transpose(levels(:))
    [ basis.nodes{i}, basis.radius(i), ...
      basis.dimensions(i) ] = configureHierarchicalLevel(i);
    basis.counts(i) = numel(basis.nodes{i});
  end
end

function [ nodes, mapping, radius, dimensions ] = computeNodes(I)
  [ indexCount, inputCount ] = size(I);

  basis = configureHierarchicalBasis(unique(I(:)));

  nodeCount = sum(basis.counts(I(:)));

  nodes = zeros(nodeCount, inputCount);
  mapping = zeros(nodeCount, 1, 'uint32');

  if nargout > 2
    radius = zeros(nodeCount, inputCount);
    dimensions = zeros(nodeCount, inputCount, 'uint32');
  end

  offset = 0;

  nodeSets = cell(1, inputCount);
  for i = 1:indexCount
    J = I(i, :);

    count = sum(basis.counts(J));
    range = (offset + 1):(offset + count);
    offset = offset + count;

    [ nodeSets{:} ] = ndgrid(basis.nodes{J});
    nodes(range, :) = cell2mat(cellfun(@(x) x(:), ...
      nodeSets, 'UniformOutput', false));
    mapping(range) = i;

    if nargout < 3, continue; end

    radius(range, :) = basis.radius(J);
    dimensions(range, :) = basis.dimensions(J);
  end

  assert(nodeCount == offset);
end

function [ newValues, newNodes, newMapping ] = ...
  evaluateBasis(I, index, surpluses)

  [ newNodes, newMapping ] = computeNodes(I);

  newNodeCount = size(newNodes, 1);
  outputCount = size(surpluses, 2);

  [ nodes, ~, radius, dimensions ] = computeNodes(index);
  assert(size(nodes, 1) == size(surpluses, 1));

  newValues = zeros(newNodeCount, outputCount);

  for i = 1:newNodeCount
    delta = abs(bsxfun(@minus, nodes, newNodes(i, :)));
    K = all(delta < radius, 2);
    newValues(i, :) = sum(bsxfun(@times, surpluses(K, :), ...
      prod(1 - (double(dimensions(K, :)) - 1) .* delta(K, :), 2)), 1);
  end
end
