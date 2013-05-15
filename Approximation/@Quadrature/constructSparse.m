function [ nodes, weights ] = constructSparse(this, options)
  ruleName = options.ruleName;
  dimension = options.dimension;
  order = options.order;

  switch ruleName
  case 'GaussHermite'
    [ nodes, weights ] = constructSmolyak( ...
      dimension, order, 'GaussHermiteHW', options.get('ruleArguments', {}));
  case 'GaussHermiteHW'
    [ nodes, weights ] = nwspgr('gqn', dimension, order);
  otherwise
    assert(false);
  end
end

function [ nodes, weights ] = constructSmolyak( ...
  dimension, order, name, arguments)

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

    %
    % Merge repeated nodes.
    %
    [ nodes, I ] = sortrows(nodes);
    weights = weights(I);
    keepIndex = 1;
    lastKeep = 1;

    for j = 2:size(nodes, 1)
      if nodes(j, :) == nodes(j - 1, :)
        weights(lastKeep) = weights(lastKeep) + weights(j);
      else
        lastKeep = j;
        keepIndex = [ keepIndex; j ];
      end
    end

    nodes = nodes(keepIndex, :);
    weights = weights(keepIndex);
  end

  %
  % Normalize the weights.
  %
  weights = weights / sum(weights);
end
