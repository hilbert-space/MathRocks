function [ nodes, weights ] = constructTensor(this, options)
  dimensionCount = options.dimensionCount;
  order = options.order;

  ruleName = options.ruleName;
  ruleArguments = options.get('ruleArguments', {});

  nodeSet = cell(1, dimensionCount);
  weightSet = cell(1, dimensionCount);

  [ nodes, weights ] = feval(ruleName, order, ruleArguments{:});
  for i = 1:dimensionCount
    nodeSet{i} = nodes;
    weightSet{i} = weights;
  end

  [ nodes, weights ] = tensor_product(nodeSet, weightSet);
end
