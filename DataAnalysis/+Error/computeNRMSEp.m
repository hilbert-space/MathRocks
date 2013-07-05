function error = computeNRMSEp(varargin)
  error = 100 * Error.computeNRMSE(varargin{:});
end
