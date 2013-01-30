function error = computeL2(observed, predicted, dimension)
  %
  % Computes the norm in L2.
  %
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sqrt(sum((observed - predicted).^2, dimension));
end
