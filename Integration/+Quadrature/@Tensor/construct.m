function [ nodes, weights ] = construct(this, options)
  dimension = options.dimension;
  level = options.level;
  rules = options.rules;

  nodeSet = cell(1, dimension);
  weightSet = cell(1, dimension);

  if isa(rules, 'cell')
    for i = 1:dimension
      [ nodes, weights ] = Quadrature.Rules.(rules{i})(level);
      nodeSet{i} = nodes;
      weightSet{i} = weights;
    end
  else
    [ nodes, weights ] = Quadrature.Rules.(rules)(level);
    for i = 1:dimension
      nodeSet{i} = nodes;
      weightSet{i} = weights;
    end
  end

  [ nodes, weights ] = tensor_product(nodeSet, weightSet);
end
