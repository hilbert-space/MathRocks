function error = computeMeanL2(observed, predicted, dimension)
  %
  % Computes the mean L2 error.
  %
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sqrt(sum((observed - predicted).^2, dimension)) ./ ...
    size(observed, dimension);
end
