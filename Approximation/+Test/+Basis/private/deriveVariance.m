function result = deriveVariance(basis, varargin)
  result = call(basis, 'deriveSecondRawMoment', varargin{:}) - ...
    call(basis, 'deriveExpectation', varargin{:})^2;
end
