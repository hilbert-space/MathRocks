classdef Exponential < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    mu
  end

  methods
    function this = Exponential(varargin)
      this = this@ProbabilityDistribution.Base(varargin{:});

      options = Options('mu', 1, varargin{:});

      this.mu = options.mu;

      this.expectation = this.mu;
      this.variance = this.mu^2;

      this.support = [ 0, Inf ];
    end

    function data = sample(this, samples, dimension)
      data = exprnd(this.mu, samples, dimension);
    end

    function data = cdf(this, data)
      data = expcdf(data, this.mu);
    end

    function data = icdf(this, data)
      data = expinv(data, this.mu);
    end

    function data = pdf(this, data)
      error('Not implemented yet.');
    end
  end
end
