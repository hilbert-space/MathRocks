function [ model, performance ] = construct(this, f, options)
  inputCount = options.get('inputCount', 1);

  verbose = @(varargin) [];
  if options.get('verbose', false)
    verbose = @(varargin) fprintf(varargin{:});
  end

  if options.has('nodes')
    nodes = options.nodes;
    nodeCount = size(nodes, 1);
  else
    nodeCount = options.get('nodeCount', 10 * inputCount);
    nodes = lhsdesign(nodeCount, inputCount);
  end

  verbose('Kriging: collecting data (%d nodes)...\n', nodeCount);

  time = tic;
  data = f(nodes);
  verbose('Kriging: done in %.2f seconds.\n', toc(time));

  regression  = options.get('regressionModel',  @regpoly0);
  correlation = options.get('correlationModel', @corrgauss);
  parameters  = options.get('parameters',        ones(1, inputCount));
  lowerBound  = options.get('lowerBound', 1e-3 * ones(1, inputCount));
  upperBound  = options.get('upperBound', 1e+1 * ones(1, inputCount));

  verbose('Kriging: processing the data (%d inputs, %d outputs)...\n', ...
    inputCount, size(data, 2));

  time = tic;
  [ this.model, this.performance ] = dacefit(nodes, data, ...
    regression, correlation, parameters, lowerBound, upperBound);
  verbose('Kriging: done in %.2f seconds.\n', toc(time));
end

function nodes = constructSmolyak(dimension, order)
  nodeSet = cell(order, 1);
  nodeCountSet = zeros(1, order);

  for i = 1:order
    nodeSet{i} = nwspgr('gqn', 1, order);
    nodeCountSet(i) = size(nodeSet{i}, 1);
  end

  nodes = [];
  nodeCount = 0;

  minq = max(0, order - dimension);
  maxq = order - 1;

  for q = minq:maxq
    indexSet = get_seq(dimension, dimension + q);

    newNodeCount = prod(nodeCountSet(indexSet), 2);
    totalNewPoints = sum(newNodeCount);

    nodes = [ nodes; zeros(totalNewPoints, dimension) ];

    for j = 1:size(indexSet, 1)
      index = indexSet(j, :);

      newNodes = computeTensorProduct(nodeSet(index));
      nodes((nodeCount + 1):(nodeCount + newNodeCount(j)), :) = newNodes;

      nodeCount = nodeCount + newNodeCount(j);
    end
  end

  i = 0;
  while true
    nodeCount = size(nodes, 1);

    i = i + 1;
    if i >= nodeCount, break; end

    I = [];
    for j = (i + 1):nodeCount
      delta = norm(nodes(i, :) - nodes(j, :), Inf);
      if delta > sqrt(2) * eps, continue; end
      I(end + 1) = j;
    end
    if isempty(I), continue; end

    nodes(I, :) = [];
  end

  nodes(abs(nodes) < sqrt(2) * eps) = 0;
end

function nodes = computeTensorProduct(nodeSet)
  dimension = length(nodeSet);

  nodes = nodeSet{1};
  nodes = nodes(:);

  for i = 2:dimension
    newNodes = nodeSet{i};
    newNodes = newNodes(:);

    a = ones(size(newNodes, 1), 1);
    b = ones(size(nodes, 1), 1);
    c = kron(nodes, a);
    d = kron(b, newNodes);

    nodes = [ c, d ];
  end
end
