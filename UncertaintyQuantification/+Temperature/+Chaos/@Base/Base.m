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
          options.surrogateOptions);
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
          options.surrogateOptions);
      otherwise
        assert(false);
      end
    end

    function [ Texp, output ] = expand(this, Pdyn, varargin)
      function result = target(rvs)
        sampleCount = size(rvs, 1);
        L = transpose(this.process.evaluate(rvs));
        T = this.computeWithLeakage(Pdyn, 'L', L, varargin{:});
        result = transpose(reshape(T, [], sampleCount));
      end

      coefficients = this.chaos.expand(@target, varargin{:});
      [ termCount, outputCount ] = size(coefficients);

      Texp = reshape(coefficients(1, :), this.processorCount, []);

      if nargout < 2, return; end

      output.Tvar = reshape(sum(coefficients(2:end, :).^2 .* ...
        Utils.replicate(this.chaos.norm(2:end), 1, outputCount), 1), ...
        this.processorCount, []);

      output.coefficients = reshape(coefficients, termCount, ...
        this.processorCount, []);
    end

    function Tdata = sample(this, output, sampleCount)
      Tdata = this.chaos.sample(sampleCount, output.coefficients);
    end

    function Tdata = evaluate(this, output, rvs)
      Tdata = this.chaos.evaluate(rvs, output.coefficients);
    end
  end
end
