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

    function [ Texp, output ] = expand(this, Pdyn, options)
      function T = target(rvs)
        V = this.preprocess(rvs, options);
        [ T, solveOutput ] = this.computeWithLeakage(Pdyn, Options(options, 'V', V));
        T = this.postprocess(T, solveOutput, options);
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

  methods (Access = 'protected')
      function V = preprocess(this, rvs, options)
      V = transpose(this.process.evaluate(rvs));

      if ~options.get('verbose', false), return; end

      VMin = sum(V(:) < this.leakage.VRange(1));
      VMax = sum(V(:) > this.leakage.VRange(2));

      if VMin == 0 && VMax == 0, return; end

      warning([ 'Detected %d and %d values below the minimal one', ...
        ' and above the maximal one, respectively, out of %d.' ], ...
        VMin, VMax, prod(size(V)));
    end

    function T = postprocess(this, T, output, options)
      sampleCount = size(T, 3);
      T = transpose(reshape(T, [], sampleCount));

      if ~options.get('verbose', false), return; end

      runawayCount = sum(isnan(output.iterationCount));

      if runawayCount == 0, return; end

      warning('Detected %d thermal runaways out of %d samples.', ...
        runawayCount, sampleCount);
    end
  end
end
