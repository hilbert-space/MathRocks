function [values, rmse] = evaluate(this, nodes)
  if nargout == 1
    values = predictor(nodes, this.model);
  else
    [values, rmse] = predictor(nodes, this.model);
  end
end
