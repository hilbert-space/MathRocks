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

      this.mu = this.a * this.b;
      this.sigma = sqrt(this.a * this.b^2);
    end

    function data = sample(this, samples, dimension)
      data = gamrnd(this.a, this.b, samples, dimension);
    end

    function data = apply(this, data)
      data = gamcdf(data, this.a, this.b);
    end

    function data = invert(this, data)
      data = gaminv(data, this.a, this.b);
    end
  end
end
