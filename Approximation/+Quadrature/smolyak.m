function [ nodesND, weightsND ] = smolyak(dimensionCount, rule, level, varargin)
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
  % F. Nobile, R. Tempone, and C. Webster. A Sparse Grid Stochastic
  % Collocation Method for Partial Differential Equations with Random
  % Input Data. SIAM Journal on Numerical Analysis, 2008.
  %
  epsilon = sqrt(eps);

  [ indexes, levels ] =  MultiIndex.smolyakLevels( ...
    dimensionCount, level, varargin{:});

  maximalLevel = max(levels);

  nodes1D = cell(1, maximalLevel + 1);
  weights1D = cell(1, maximalLevel + 1);
  counts1D = zeros(1, maximalLevel + 1);

  for i = 1:(maximalLevel + 1)
    [ nodes1D{i}, weights1D{i} ] = feval(rule, i - 1);
    counts1D(i) = length(weights1D{i});
  end

  maximalNodeCount = 100 * dimensionCount;

  nodesND = zeros(maximalNodeCount, dimensionCount);
  weightsND = zeros(maximalNodeCount, 1);
  nodeCount = 0;

  unity = MultiIndex.tensorProductSpace(dimensionCount, 1);
  allin = cell2mat(indexes);

  for i = 1:length(indexes)
    counts = prod(counts1D(indexes{i} + 1), 2);

    %
    % Allocate more memory when needed
    %
    addition = nodeCount + sum(counts) - maximalNodeCount;
    if addition > 0
      addition = max(addition, maximalNodeCount);
      nodesND = [ nodesND; zeros(addition, dimensionCount) ];
      weightsND = [ weightsND; zeros(addition, 1) ];
      maximalNodeCount = maximalNodeCount + addition;
    end

    %
    % Tensor the one-dimensional rules
    %
    for j = 1:size(indexes{i}, 1)
      index = indexes{i}(j, :);

      I = ismember(bsxfun(@plus, unity, index), allin, 'rows');

      coefficient = sum((-1).^(sum(unity(I, :), 2)));
      if coefficient == 0, continue; end

      range = (nodeCount + 1):(nodeCount + counts(j));

      nodesND(range, :) = Utils.tensor(nodes1D(index + 1));
      weightsND(range) = coefficient * prod(Utils.tensor( ...
        weights1D(index + 1)), 2);

      nodeCount = nodeCount + counts(j);
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

  j = 1;
  for i = 2:nodeCount
    if I(i - 1)
      weightsND(j) = weightsND(j) + weightsND(i);
    else
      j = i;
      J(i) = true;
    end
  end

  nodesND = nodesND(J, :);
  weightsND = weightsND(J);

  weightsND = weightsND / sum(weightsND);
end
