function result = deriveVariance(this, varargin)
  result = this.deriveSecondRawMoment(varargin{:}) - ...
    this.deriveExpectation(varargin{:})^2;
end
