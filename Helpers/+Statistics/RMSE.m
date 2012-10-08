function rmse = RMSE(observed, predicted, offset)
  o = observed(:);
  p = predicted(:);
  rmse = sqrt(sum((o - p) .^ 2) / numel(o));
end
