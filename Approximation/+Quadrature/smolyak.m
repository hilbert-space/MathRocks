function [ nodes, weights ] = smolyak(dimensionCount, rule, level, varargin)
  [ indexes, levels, isAnisotropic ] = MultiIndex.smolyakLevels( ...
    dimensionCount, level, varargin{:});

  level = max(levels);

  nodes1D = cell(1, level + 1);
  weights1D = cell(1, level + 1);
  counts1D = zeros(1, level + 1);

  for i = 1:(level + 1)
    [ nodes1D{i}, weights1D{i} ] = feval(rule, i - 1);
    counts1D(i) = length(weights1D{i});
  end

  if ~isAnisotropic
    [ nodes, weights ] = isotropic(dimensionCount, ...
      indexes, levels, nodes1D, weights1D, counts1D);
  else
    [ nodes, weights ] = anisotropic(dimensionCount, ...
      indexes, levels, nodes1D, weights1D, counts1D);
  end

  [ nodes, weights ] = postprocess(nodes, weights);
end

function [ nodes, weights ] = isotropic( ...
  dimensionCount, indexes, levels, nodes1D, weights1D, counts1D)

  %
  % NOTE: When Gaussian quadratures with the slow-linear growth rule
  % are utilized, the sparse grid will be exact for polynomial with the
  % total order up to (2 * level + 1).
  %
  % Reference:
  %
  % http://people.sc.fsu.edu/~jburkardt/cpp_src/sgmg/sgmg.html
  %

  level = max(levels);

  maximalNodeCount = 100 * dimensionCount;

  nodes = zeros(maximalNodeCount, dimensionCount);
  weights = zeros(maximalNodeCount, 1);
  nodeCount = 0;

  for i = 1:length(indexes)
    counts = prod(counts1D(indexes{i} + 1), 2);

    %
    % Allocate more memory when needed
    %
    addition = nodeCount + sum(counts) - maximalNodeCount;
    if addition > 0
      addition = max(addition, maximalNodeCount);
      nodes = [ nodes; zeros(addition, dimensionCount) ];
      weights = [ weights; zeros(addition, 1) ];
      maximalNodeCount = maximalNodeCount + addition;
    end

    coefficient = (-1)^(level - levels(i)) * ...
      nchoosek(dimensionCount - 1, level - levels(i));

    %
    % Tensor the one-dimensional rules
    %
    for j = 1:size(indexes{i}, 1)
      index = indexes{i}(j, :);

      range = (nodeCount + 1):(nodeCount + counts(j));

      nodes(range, :) = Utils.tensor(nodes1D(index + 1));
      weights(range) = coefficient * prod(Utils.tensor( ...
        weights1D(index + 1)), 2);

      nodeCount = nodeCount + counts(j);
    end
  end

  nodes = nodes(1:nodeCount, :);
  weights = weights(1:nodeCount);
end

function [ nodes, weights ] = anisotropic( ...
  dimensionCount, indexes, ~, nodes1D, weights1D, counts1D)

  %
  % Reference:
  %
  % F. Nobile, R. Tempone, and C. Webster. A Sparse Grid Stochastic
  % Collocation Method for Partial Differential Equations with Random
  % Input Data. SIAM Journal on Numerical Analysis, 2008.
  %

  maximalNodeCount = 100 * dimensionCount;

  nodes = zeros(maximalNodeCount, dimensionCount);
  weights = zeros(maximalNodeCount, 1);
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
      nodes = [ nodes; zeros(addition, dimensionCount) ];
      weights = [ weights; zeros(addition, 1) ];
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

      nodes(range, :) = Utils.tensor(nodes1D(index + 1));
      weights(range) = coefficient * prod(Utils.tensor( ...
        weights1D(index + 1)), 2);

      nodeCount = nodeCount + counts(j);
    end
  end

  nodes = nodes(1:nodeCount, :);
  weights = weights(1:nodeCount);
end

function [ nodes, weights ] = postprocess(nodes, weights)
  epsilon = sqrt(eps);

  I = abs(weights) < epsilon;
  nodes(I, :) = [];
  weights(I) = [];

  nodeCount = size(nodes, 1);

  [ ~, I ] = sortrows(round(nodes / epsilon));
  nodes = nodes(I, :);
  weights = weights(I);

  I = all(abs(diff(nodes, 1)) < epsilon, 2);
  J = false(nodeCount, 1);
  J(1) = true;

  j = 1;
  for i = 2:nodeCount
    if I(i - 1)
      weights(j) = weights(j) + weights(i);
    else
      j = i;
      J(i) = true;
    end
  end

  nodes = nodes(J, :);
  weights = weights(J);

  weights = weights / sum(weights);
end
