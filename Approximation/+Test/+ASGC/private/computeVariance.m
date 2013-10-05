function result = computeVariance(varargin)
  result = computeSecondRawMoment(varargin{:}) - ...
    computeExpectation(varargin{:})^2;
end
