classdef ScaleInvChi2 < ProbabilityDistribution.Base
  properties (SetAccess = 'private')
    nu
    tau
  end

  methods
    function this = ScaleInvChi2(varargin)
      this = this@ProbabilityDistribution.Base;

      options = Options('nu', 1, 'tau', 1, varargin{:});

      nu = options.nu;
      tau = options.tau;

      this.nu = nu;
      this.tau = tau;

      this.expectation = NaN;
      this.variance = NaN;

      if nu > 2
        this.expectation = nu * tau^2 / (nu - 2);
      end

      if nu > 4
        this.variance = 2 * nu^2 * tau^4 / ((nu - 2)^2 * (nu - 4));
      end

      this.support = [0, Inf];
    end

    function data = sample(this, varargin)
      nu = this.nu;
      tau2 = this.tau^2;
      data = tau2 * nu ./ chi2rnd(nu, varargin{:});
    end

    function data = cdf(this, data)
      error('Not implemented yet.');
    end

    function data = icdf(this, data)
      error('Not implemented yet.');
    end

    function data = pdf(this, data)
      nu = this.nu;
      tau2 = this.tau^2;
      data = (tau2 * nu ./ data.^2) .* chi2pdf(tau2 * nu ./ data, nu);
    end
  end
end
