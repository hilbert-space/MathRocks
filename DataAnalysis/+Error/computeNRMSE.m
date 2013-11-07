function error = computeNRMSE(observed, predicted, dimension)
  %
  % Reference:
  %
  % https://en.wikipedia.org/wiki/Root-mean-square_deviation#Normalized_root-mean-square_deviation
  %
  if nargin < 2, predicted = 0; end
  if nargin < 3
    dimension = 1;
    observed = observed(:);
    predicted = predicted(:);
  end
  error = Error.computeRMSE(observed, predicted, dimension) ./ ...
    (max(observed, [], dimension) - min(observed, [], dimension));
end
