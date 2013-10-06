function result = computeVariance(this, varargin)
  result = this.computeSecondRawMoment(varargin{:}) - ...
    this.computeExpectation(varargin{:})^2;
end
