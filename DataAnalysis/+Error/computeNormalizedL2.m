function error = computeNormalizedL2(observed, predicted, dimension)
  %
  % Computes the normalized L2 error.
  %
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sqrt(sum((observed - predicted).^2, dimension)) ./ ...
    sqrt(sum(observed.^2, dimension));
end