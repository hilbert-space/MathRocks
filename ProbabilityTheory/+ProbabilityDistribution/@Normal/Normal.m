classdef Normal < ProbabilityDistribution.Base
  methods
    function this = Normal(varargin)
      this = this@ProbabilityDistribution.Base();

      options = Options('mu', 0, 'sigma', 1, varargin{:});

      this.mu = options.mu;
      this.sigma = options.sigma;
    end

    function data = sample(this, samples, dimension)
      data = normrnd(this.mu, this.sigma, samples, dimension);
    end

    function data = apply(this, data)
      data = normcdf(data, this.mu, this.sigma);
    end

    function data = invert(this, data)
      data = norminv(data, this.mu, this.sigma);
    end
  end
end
