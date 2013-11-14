classdef PolynomialChaos < TemperatureVariation.Base
  methods
    function this = PolynomialChaos(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = compute(this, Pdyn)
      output = this.surrogate.construct( ...
        @(rvs) this.surve(Pdyn, rvs));
    end
  end

  methods (Access = 'protected')
    function surrogate = configure(this, options)
      %
      % NOTE: For now, only one distribution.
      %
      distributions = this.process.distributions;
      distribution = distributions{1};
      for i = 2:this.process.parameterCount
        assert(distribution == distributions{i});
      end

      switch class(distribution)
      case 'ProbabilityDistribution.Gaussian'
        assert(distribution.expectation == 0);
        assert(distribution.variance == 1);

        surrogate = PolynomialChaos.Hermite( ...
          'inputCount', sum(this.process.dimensions), options);
      case 'ProbabilityDistribution.Beta'
        alpha = distribution.alpha;
        beta = distribution.beta;
        a = distribution.a;
        b = distribution.b;

        %
        % NOTE: MATLAB's interpretation of the beta distribution
        % differs from the one used in the Gauss-Jacobi quadrature rule.
        %
        surrogate = PolynomialChaos.Jacobi( ...
          'inputCount', sum(this.process.dimensions), ...
          'alpha', alpha - 1, 'beta', beta - 1, 'a', a, 'b', b, options);
      otherwise
        assert(false);
      end
    end

    function T = surve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters);
      parameters = this.process.assign(parameters);

      T = this.temperature.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
