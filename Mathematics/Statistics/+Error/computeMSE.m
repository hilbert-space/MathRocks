function error = computeMSE(observed, predicted, dimension)
  %
  % Reference:
  %
  % https://en.wikipedia.org/wiki/Mean_squared_error
  %
  if nargin < 2, predicted = 0; end
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sum((observed - predicted).^2, dimension) ./ ...
    size(observed, dimension);
end
