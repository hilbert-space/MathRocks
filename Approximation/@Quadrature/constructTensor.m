function [ nodes, weights ] = constructTensor(this, options)
  dimension = options.dimension;
  order = options.order;

  ruleName = options.ruleName;
  ruleArguments = options.get('ruleArguments', {});

  nodeSet = cell(1, dimension);
  weightSet = cell(1, dimension);

  [ nodes, weights ] = feval(ruleName, order, ruleArguments{:});
  for i = 1:dimension
    nodeSet{i} = nodes;
    weightSet{i} = weights;
  end

  [ nodes, weights ] = tensor_product(nodeSet, weightSet);
end
