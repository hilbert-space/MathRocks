classdef Base < handle
  properties (SetAccess = 'protected')
    process
    chaos
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      if options.has('process')
        this.process = options.process;
      else
        this.process = ProcessVariation.(options.processModel)( ...
          options.processOptions);
      end

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
        T = this.solve(Pdyn, Options(varargin{:}, 'L', L));
        result = transpose(reshape(T, [], sampleCount));
      end

      chaosOutput = this.chaos.expand(@target);

      Texp = reshape(chaosOutput.expectation, this.processorCount, []);

      if nargout < 2, return; end

      output.Tvar = reshape(chaosOutput.variance, this.processorCount, []);

      output.coefficients = reshape(chaosOutput.coefficients, ...
        this.chaos.termCount, this.processorCount, []);
    end

    function Tdata = sample(this, varargin)
      Tdata = this.chaos.sample(varargin{:});
    end

    function Tdata = evaluate(this, varargin)
      Tdata = this.chaos.evaluate(varargin{:});
    end
  end
end
