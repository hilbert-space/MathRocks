classdef Gaussian < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    mu
    sigma
  end

  methods
    function this = Gaussian(varargin)
      this = this@ProbabilityDistribution.Base;

      options = Options('mu', 0, 'sigma', 1, varargin{:});

      this.mu = options.mu;
      this.sigma = options.sigma;

      this.expectation = options.mu;
      this.variance = options.sigma^2;

      this.support = [ -Inf, Inf ];
    end

    function data = sample(this, varargin)
      data = normrnd(this.mu, this.sigma, varargin{:});
    end

    function data = cdf(this, data)
      data = normcdf(data, this.mu, this.sigma);
    end

    function data = icdf(this, data)
      data = norminv(data, this.mu, this.sigma);
    end

    function data = pdf(this, data)
      data = normpdf(data, this.mu, this.sigma);
    end
  end
end
