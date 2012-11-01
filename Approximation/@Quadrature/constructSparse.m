function [ nodes, weights ] = constructSparse(this, options)
  ruleName = options.ruleName;
  dimension = options.dimension;
  order = options.order;

  switch ruleName
  case 'GaussHermiteHW'
    [ nodes, weights ] = nwspgr('gqn', dimension, order);
  otherwise
    [ nodes, weights ] = constructSmolyak( ...
      dimension, order, ruleName, options.get('ruleArguments', {}));
  end
end

function [ nodes, weights ] = constructSmolyak(dimension, order, name, arguments)
  %
  % Florian Heiss and Viktor Winschel, Likelihood approximation by numerical
  % integration on sparse grids, Journal of Econometrics, Volume 144, 2008,
  % pages 62-80.
  %
  nodeSet = cell(order, 1);
  weightSet = cell(order, 1);
  nedeCountSet = zeros(1, order);

  for i = 1:order
    [ nodeSet{i}, weightSet{i} ] = feval(name, i, arguments{:});
    nodeCountSet(i) = length(weightSet{i});
  end

  nodes = [];
  weights = [];
  nodeCount = 0;

  minq = max(0, order - dimension);
  maxq = order - 1;

  for q = minq:maxq
    coefficient = (-1)^(maxq - q) * ...
      nchoosek(dimension - 1, dimension + q - order);

    indexSet = get_seq(dimension, dimension + q);

    newNodeCount = prod(nodeCountSet(indexSet), 2);
    totalNewPoints = sum(newNodeCount);

    nodes = [ nodes; zeros(totalNewPoints, dimension) ];
    weights = [ weights; zeros(totalNewPoints, 1) ];

    for j = 1:size(indexSet, 1)
      index = indexSet(j, :);

      [ newNodes, newWeights ] = ...
        tensor_product(nodeSet(index), weightSet(index));

      nodes  ((nodeCount + 1):(nodeCount + newNodeCount(j)), :) = newNodes;
      weights((nodeCount + 1):(nodeCount + newNodeCount(j))) = coefficient * newWeights;

      nodeCount = nodeCount + newNodeCount(j);
    end
  end

  %
  % Merge repeated nodes.
  %
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

    weights(i) = weights(i) + sum(weights(I));
    nodes(I, :) = [];
    weights(I) = [];
  end

  % nodes(abs(nodes) < sqrt(2) * eps) = 0;

  [ nodes, I ] = sortrows(nodes);
  weights = weights(I);

  weights = weights / sum(weights);
end
