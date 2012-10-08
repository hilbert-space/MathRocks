classdef Exponential < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    lambda
  end

  methods
    function this = Exponential(varargin)
      this = this@ProbabilityDistribution.Base(varargin{:});

      options = Options('lambda', 1, varargin{:});

      this.lambda = options.lambda;

      this.mu = 1 / this.lambda;
      this.sigma = sqrt(this.mu);
    end

    function data = sample(this, samples, dimension)
      data = exprnd(1, samples, dimension);
    end

    function data = apply(this, data)
      data = expcdf(data);
    end

    function data = invert(this, data)
      data = expinv(data);
    end
  end
end
