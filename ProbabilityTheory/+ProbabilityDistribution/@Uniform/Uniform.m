classdef Uniform < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    a
    b
  end

  methods
    function this = Uniform(varargin)
      this = this@ProbabilityDistribution.Base;

      options = Options('a', 0, 'b', 1, varargin{:});

      this.a = options.a;
      this.b = options.b;

      this.expectation = (this.a + this.b) / 2;
      this.variance = (this.b - this.a)^2 / 12;

      this.support = [ this.a, this. b ];
    end

    function data = sample(this, varargin)
      data = unifrnd(this.a, this.b, varargin{:});
    end

    function data = cdf(this, data)
      data = unifcdf(data, this.a, this.b);
    end

    function data = icdf(this, data)
      data = unifinv(data, this.a, this.b);
    end

    function data = pdf(this, data)
      data = unifpdf(data, this.a, this.b);
    end
  end
end
