function error = computeInf(observed, predicted, varargin)
  if nargin < 2, predicted = 0; end
  error = Norm.computeInf(observed - predicted, varargin{:});
end
