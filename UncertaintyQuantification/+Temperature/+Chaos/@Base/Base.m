classdef Base < handle
  properties (SetAccess = 'protected')
    process
    chaos
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.process = ProcessVariation.(options.processModel)( ...
        options.processOptions);

      switch options.processModel
      case 'Normal'
        this.chaos = PolynomialChaos.Hermite( ...
          'inputCount', this.process.dimensionCount, ...
          'quadratureOptions', Options( ...
            'ruleName', 'GaussHermiteHW'), ...
          options.chaosOptions);
      case 'Beta'
        distribution = this.process.transformation.customDistribution;

        alpha = distribution.alpha;
        beta = distribution.beta;
        a = distribution.a;
        b = distribution.b;

        %
        % NOTE: MATLAB's interpretation of the beta distribution
        % differs from the one used in the Gauss-Jacobi quadrature rule.
        %
        this.chaos = PolynomialChaos.Jacobi( ...
          'inputCount', this.process.dimensionCount, ...
          'alpha', alpha - 1, 'beta', beta - 1, 'a', a, 'b', b, ...
          'quadratureOptions', Options('ruleName', 'GaussJacobi'), ...
          options.chaosOptions);
      otherwise
        assert(false);
      end
    end

    function [ Texp, output ] = expand(this, Pdyn, varargin)
      [ processorCount, stepCount ] = size(Pdyn);

      chaos = this.chaos;
      process = this.process;

      function result = target(rvs)
        L = transpose(process.evaluate(rvs));
        T = this.computeWithLeakage(Pdyn, 'L', L, varargin{:});
        result = transpose(reshape(T, processorCount * stepCount, []));
      end

      coefficients = chaos.expand(@target, varargin{:});

      Texp = reshape(coefficients(1, :), processorCount, stepCount);

      if nargout < 2, return; end

      outputCount = processorCount * stepCount;

      output.Tvar = reshape(sum(coefficients(2:end, :).^2 .* ...
        Utils.replicate(chaos.norm(2:end), 1, outputCount), 1), ...
        processorCount, stepCount);

      output.coefficients = reshape(coefficients, chaos.termCount, ...
        processorCount, stepCount);
    end

    function Tdata = sample(this, output, sampleCount)
      Tdata = this.chaos.sample(sampleCount, output.coefficients);
    end

    function Tdata = evaluate(this, output, rvs)
      Tdata = this.chaos.evaluate(rvs, output.coefficients);
    end
  end
end
