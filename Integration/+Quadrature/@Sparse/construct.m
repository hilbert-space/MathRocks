function [ nodes, weights ] = construct(this, options)
  dimension = options.dimension;
  maxLevel = options.level;
  rules = options.rules;

  assert(isa(rules, 'char'), ...
    'Only isotropic grids are currently supported.');

  minLevel = max(0, maxLevel - dimension + 1);

  pointSet = zeros(1, maxLevel);
  nodeSet = cell(maxLevel);
  weightSet = cell(maxLevel);

  %
  % Compute one-dimensional rules for all the needed levels.
  %
  for level = 1:maxLevel
    [ nodeSet{level}, weightSet{level} ] = Quadrature.Rules.(rules)(level);
    pointSet(level) = length(weightSet{level});
  end

  points = 0;
  nodes = [];
  weights = [];

  for level = minLevel:maxLevel
    coefficient = (-1)^(maxLevel - level) * ...
      nchoosek(dimension - 1, maxLevel - level);

    %
    % Compute all combinations of positive integers that
    % sum up to `dimension + level - 1'.
    %
    indexSet = get_seq(dimension, dimension + level - 1);

    newPoints = prod(pointSet(indexSet), 2);
    totalNewPoints = sum(newPoints);

    %
    % Preallocate space for new points.
    %
    nodes = [ nodes; zeros(totalNewPoints, dimension) ];
    weights = [ weights; zeros(totalNewPoints, 1) ];

    %
    % Append the new nodes and weights.
    %
    for i = 1:size(indexSet, 1)
      index = indexSet(i, :);

      [ newNodes, newWeights ] = ...
        tensor_product(nodeSet(index), weightSet(index));

      nodes((points + 1):(points + newPoints(i)), :) = newNodes;
      weights((points + 1):(points + newPoints(i))) = coefficient * newWeights;

      points = points + newPoints(i);
    end

    %
    % Sort the nodes.
    %
    [ nodes, I ] = sortrows(nodes);
    weights = weights(I);

    %
    % Merge repeated values.
    %
    keep = [ 1 ];
    last = 1;

    for i = 2:size(nodes, 1)
      if nodes(i, :) == nodes(i - 1, :)
        weights(last) = weights(last) + weights(i);
      else
        last = i;
        keep = [ keep; i ];
      end
    end

    nodes = nodes(keep, :);
    weights = weights(keep);
  end

  %
  % Normalize the weights.
  %
  weights = weights / sum(weights);
end
