function error = computeRMSE(observed, predicted, dimension)
  %
  % Reference:
  %
  % https://en.wikipedia.org/wiki/Root_mean_square_deviation
  %
  if nargin < 2, predicted = 0; end
  if nargin < 3
   observed = observed(:);
   predicted = predicted(:);
   dimension = 1;
  end
  error = sqrt(Error.computeMSE(observed, predicted, dimension));
end
