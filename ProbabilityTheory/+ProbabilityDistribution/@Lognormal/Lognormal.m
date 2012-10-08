classdef Lognormal < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    normalMu
    normalSigma
  end

  methods
    function this = Lognormal(varargin)
      this = this@ProbabilityDistribution.Base();

      options = Options('normalMu', 0, 'normalSigma', 1, varargin{:});

      this.normalMu = options.normalMu;
      this.normalSigma = options.normalSigma;

      this.mu = exp(this.normalMu + this.normalSigma^2 / 2);
      this.sigma = sqrt((exp(this.normalSigma^2) - 1) * ...
        exp(2 * this.normalMu + this.normalSigma^2));
    end

    function data = sample(this, samples, dimension)
      data = lognrnd(this.normalMu, this.normalSigma, samples, dimension);
    end

    function data = apply(this, data)
      data = logncdf(data, this.normalMu, this.normalSigma);
    end

    function data = invert(this, data)
      data = logninv(data, this.normalMu, this.normalSigma);
    end
  end
end
