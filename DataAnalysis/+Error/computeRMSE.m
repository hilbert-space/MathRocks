function error = computeRMSE(observed, predicted, dimension)
  %
  % Computes the root-mean-square error.
  %
  if nargin < 2, predicted = 0; end
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sqrt(sum((observed - predicted).^2, dimension) ./ ...
    size(observed, dimension));
end
