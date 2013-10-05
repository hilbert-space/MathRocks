function result = deriveVariance(varargin)
  result = deriveSecondRawMoment(varargin{:}) - ...
    deriveExpectation(varargin{:})^2;
end
