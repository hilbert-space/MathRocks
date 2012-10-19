function error = computeNormalizedMeanL2(observed, predicted)
  %
  % Computes the normalized mean L2 error.
  %
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sqrt(sum((observed - predicted).^2, dimension)) ./ ...
    size(observed, dimension) ./ ...
    (max(observed, [], dimension) - min(observed, [], dimension));
end
