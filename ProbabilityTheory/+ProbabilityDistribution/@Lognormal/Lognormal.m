classdef Lognormal < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    mu
    sigma
  end

  methods
    function this = Lognormal(varargin)
      this = this@ProbabilityDistribution.Base();

      options = Options('mu', 0, 'sigma', 1, varargin{:});

      this.mu = options.mu;
      this.sigma = options.sigma;

      this.expectation = exp(this.mu + this.sigma^2 / 2);
      this.variance = (exp(this.sigma^2) - 1) * ...
        exp(2 * this.mu + this.sigma^2);

      this.support = [ 0, Inf ];
    end

    function data = sample(this, samples, dimension)
      data = lognrnd(this.mu, this.sigma, samples, dimension);
    end

    function data = apply(this, data)
      data = logncdf(data, this.mu, this.sigma);
    end

    function data = invert(this, data)
      data = logninv(data, this.mu, this.sigma);
    end

    function data = pdf(this, data)
      data = lognpdf(data, this.mu, this.sigma);
    end
  end
end
