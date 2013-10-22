classdef Base < Temperature.Surrogate
  properties (SetAccess = 'protected')
    process
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.process = ProcessVariation(options.processOptions);

      %
      % NOTE: For now, we do not attempt to combine different
      % polynomial bases.
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

        this.surrogate = PolynomialChaos.Hermite( ...
          'inputCount', sum(this.process.dimensions), ...
          'quadratureOptions', Options('ruleName', 'GaussHermiteHW'), ...
          options.surrogateOptions);
      case 'ProbabilityDistribution.Beta'
        alpha = distribution.alpha;
        beta = distribution.beta;
        a = distribution.a;
        b = distribution.b;

        %
        % NOTE: MATLAB's interpretation of the beta distribution
        % differs from the one used in the Gauss-Jacobi quadrature rule.
        %
        this.surrogate = PolynomialChaos.Jacobi( ...
          'inputCount', sum(this.process.dimensions), ...
          'alpha', alpha - 1, 'beta', beta - 1, 'a', a, 'b', b, ...
          'quadratureOptions', Options('ruleName', 'GaussJacobi'), ...
          options.surrogateOptions);
      otherwise
        assert(false);
      end
    end

    function output = expand(this, Pdyn)
      output = this.surrogate.expand(@(rvs) this.postprocess( ...
        this.computeWithLeakage(Pdyn, this.preprocess(rvs))));
      output.stepCount = size(Pdyn, 2);
    end
  end

  methods (Access = 'protected')
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
