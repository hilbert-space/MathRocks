classdef Base < Temperature.Surrogate
  methods
    function this = Base(varargin)
      this = this@Temperature.Surrogate(varargin{:});
    end

    function output = expand(this, Pdyn)
      output = this.surrogate.expand(@(rvs) this.postprocess( ...
        this.computeWithLeakage(Pdyn, this.preprocess(rvs))));
      output.stepCount = size(Pdyn, 2);
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

    function parameters = preprocess(this, rvs)
      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters);
      parameters = cellfun(@transpose, parameters, 'UniformOutput', false);
      parameters = this.process.assign(parameters);
    end

    function T = postprocess(~, T)
      sampleCount = size(T, 3);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
