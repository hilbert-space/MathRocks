function result = evaluateVariance(varargin)
  result = evaluateSecondRawMoment(varargin{:}) - ...
    evaluateExpectation(varargin{:})^2;
end
