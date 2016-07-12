function error = computeL2(observed, predicted, varargin)
  if nargin < 2, predicted = 0; end
  error = Norm.computeL2(observed - predicted, varargin{:});
end
