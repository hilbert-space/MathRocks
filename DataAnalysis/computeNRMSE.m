function nrmse = computeNRMSE(observed, predicted)
  o = observed(:);
  p = predicted(:);
  nrmse = sqrt(sum((o - p) .^ 2) / numel(o)) / (max(o) - min(o));
end
