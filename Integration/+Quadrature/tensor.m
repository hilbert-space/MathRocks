function [nodesND, weightsND] = tensor(dimensionCount, rule, level)
  [nodes1D, weights1D] = rule(level);
  nodesND = Utils.tensor(repmat({ nodes1D }, 1, dimensionCount));
  weightsND = prod(Utils.tensor(repmat({ weights1D }, 1, dimensionCount)), 2);
end
