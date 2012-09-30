function [ Nodes, Weights, Index, Map ] = construct(this, f, options)
  dimension = options.dimension;
  maxLevel = options.maxLevel;
  minLevel = max(0, maxLevel - dimension + 1);

  pointSet = zeros(1, maxLevel);
  nodeSet = cell(maxLevel);

  %
  % Compute one-dimensional rules for all the needed levels.
  %
  for level = 1:maxLevel
    pointSet(level) = this.countNodes(level);
    nodeSet{level} = this.computeNodes(level, pointSet(level));
  end

  points = 0;

  Nodes = [];
  Weights = [];
  Index = [];
  Map = [];

  for level = minLevel:maxLevel
    coefficient = (-1).^(this.maxLevel - level) .* ...
      nchoosek(dimension - 1, maxLevel - level);

    %
    % Compute all combinations of positive integers that
    % sum up to `dimension + level - 1'.
    %
    index = constructMultiIndex(dimension, dimension + level - 1);

    newPoints = prod(pointSet(index), 2);
    totalNewPoints = sum(newPoints);

    %
    % Preallocate space for new points.
    %
    Nodes = [ Nodes; zeros(totalNewPoints, dimension) ];
    Weights = [ Weights; ones(totalNewPoints, 1) ];
    Map = [ Map; zeros(totalNewPoints, 1) ];

    %
    % Append the nodes.
    %
    for i = 1:size(index, 1)
      newNodes = constructTensorProduct(nodeSet(index(i, :)));
      Nodes((points + 1):(points + newPoints(i)), :) = newNodes;
      Weights((points + 1):(points + newPoints(i))) = coefficient * f(newNodes);
      Map((points + 1):(points + newPoints(i))) = size(Index, 1) + i;
      points = points + newPoints(i);
    end

    %
    % Extend the index.
    %
    Index = [ Index; index ];
  end
end

function nodes = constructTensorProduct(nodeSet)
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

function index = constructMultiIndex(dimension, norm)
  assert(norm >= dimension, 'The input parameters are invalid.');

  sequence = zeros(1, dimension);

  a = norm - dimension;
  sequence(1) = a;
  index = sequence;
  c = 1;

  while sequence(dimension) < a
    if c == dimension
      for i = (c - 1):(-1):1
        c = i;
        if sequence(i) ~= 0, break; end
      end
    end

    sequence(c) = sequence(c) - 1;
    c = c + 1;
    sequence(c) = a - sum(sequence(1:(c - 1)));

    if c < dimension
      sequence((c + 1):dimension) = zeros(1, dimension - c);
    end

    index = [ index; sequence ];
  end

  index = index + 1;
end
