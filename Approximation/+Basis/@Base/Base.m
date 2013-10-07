classdef Base < handle
  properties (SetAccess = 'private')
    support
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.support = options.support;
    end

    function result = estimateExpectation(this, i, j)
      result = integral(@(Y) this.evaluate(i, j, Y(:)), ...
        this.support(1), this.support(2));
    end

    function result = estimateVariance(this, varargin)
      result = this.estimateSecondRawMoment(varargin{:}) - ...
        this.estimateExpectation(varargin{:})^2;
    end

    function result = estimateSecondRawMoment(this, i, j)
      result = integral(@(Y) this.evaluate(i, j, Y(:)).^2, ...
        this.support(1), this.support(2));
    end

    function result = estimateCrossExpectation(this, i1, j1, i2, j2)
      result = integral(@(Y) this.evaluate(i1, j1, Y(:)) .* ...
        this.evaluate(i2, j2, Y(:)), this.support(1), this.support(2));
    end

    function result = estimateCovariance(this, i1, j1, i2, j2)
      result = this.estimateCrossExpectation(i1, j1, i2, j2) - ...
        this.estimateExpectation(i1, j1) * this.estimateExpectation(i2, j2);
    end
  end
end
