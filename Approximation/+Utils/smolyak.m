function [ nodesND, weightsND ] = smolyak( ...
  dimensionCount, rule, level, varargin)

  %
  % NOTE 1: The level parameter start from zero. Due to the one-based
  % indexation of MATLAB, we need to have +1 in some parts of the code
  % given below.
  %
  % NOTE 2: When Gaussian quadratures with the slow-linear growth rule
  % are utilized, the sparse grid will be exact for polynomial with the
  % total order up to (2 * level + 1).
  %
  % Reference:
  %
  % http://people.sc.fsu.edu/~jburkardt/cpp_src/sgmg/sgmg.html
  %

  epsilon = sqrt(eps);
  maximalNodeCount = 100 * dimensionCount;

  nodesND = zeros(maximalNodeCount, dimensionCount);
  weightsND = zeros(maximalNodeCount, 1);
  nodeCount = 0;

  nodes1D = cell(1, level + 1);
  weights1D = cell(1, level + 1);
  counts1D = zeros(1, level + 1);

  for q = 0:level
    i = q + 1;
    [ nodes1D{i}, weights1D{i} ] = feval(rule, q, varargin{:});
    counts1D(i) = length(weights1D{i});
  end

  for q = max(0, level - dimensionCount + 1):level
    coefficient = (-1)^(level - q) * nchoosek(dimensionCount - 1, level - q);

    indexes = Utils.indexSmolyakLevel(dimensionCount, q) + 1;
    counts = prod(counts1D(indexes), 2);

    addition = nodeCount + sum(counts) - maximalNodeCount;
    if addition > 0
      addition = max(addition, maximalNodeCount);
      nodesND = [ nodesND; zeros(addition, dimensionCount) ];
      weightsND = [ weightsND; zeros(addition, 1) ];
      maximalNodeCount = maximalNodeCount + addition;
    end

    for i = 1:size(indexes, 1)
      range = (nodeCount + 1):(nodeCount + counts(i));

      nodesND(range, :) = Utils.tensor(nodes1D(indexes(i, :)));
      weightsND(range) = coefficient * ...
        prod(Utils.tensor(weights1D(indexes(i, :))), 2);

      nodeCount = nodeCount + counts(i);
    end
  end

  nodesND = nodesND(1:nodeCount, :);
  weightsND = weightsND(1:nodeCount);

  I = abs(weightsND) < epsilon;
  nodesND(I, :) = [];
  weightsND(I) = [];

  nodeCount = size(nodesND, 1);

  [ ~, I ] = sortrows(round(nodesND / epsilon));
  nodesND = nodesND(I, :);
  weightsND = weightsND(I);

  I = all(abs(diff(nodesND, 1)) < epsilon, 2);
  J = false(nodeCount, 1);
  J(1) = true;

  k = 1;
  for i = 2:nodeCount
    if I(i - 1)
      weightsND(k) = weightsND(k) + weightsND(i);
    else
      k = i;
      J(i) = true;
    end
  end

  nodesND = nodesND(J, :);
  weightsND = weightsND(J);

  weightsND = weightsND / sum(weightsND);
end
