function error = computeMSE(observed, predicted, dimension)
  %
  % Computes the mean-square error.
  %
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sum((observed - predicted).^2, dimension) ./ ...
    size(observed, dimension);
end
