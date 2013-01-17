function [ values, rmse ] = evaluate(this, nodes)
  [ values, rmse ] = predictor(nodes, this.model);
end
