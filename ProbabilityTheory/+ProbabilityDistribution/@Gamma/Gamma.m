classdef Gamma < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    a
    b
  end

  methods
    function this = Gamma(varargin)
      this = this@ProbabilityDistribution.Base()

      options = Options('a', 0, 'b', 1, varargin{:});

      this.a = options.a;
      this.b = options.b;

      this.expectation = this.a * this.b;
      this.variance = this.a * this.b^2;

      this.support = [ 0, Inf ];
    end

    function data = sample(this, varargin)
      data = gamrnd(this.a, this.b, varargin{:});
    end

    function data = cdf(this, data)
      data = gamcdf(data, this.a, this.b);
    end

    function data = icdf(this, data)
      data = gaminv(data, this.a, this.b);
    end

    function data = pdf(this, data)
      error('Not implemented yet.');
    end
  end
end
