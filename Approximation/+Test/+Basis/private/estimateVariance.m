function result = estimateVariance(varargin)
  result = estimateSecondRawMoment(varargin{:}) - ...
    estimateExpectation(varargin{:})^2;
end
