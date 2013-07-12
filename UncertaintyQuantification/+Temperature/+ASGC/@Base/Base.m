classdef Base < handle
  properties (SetAccess = 'protected')
    process
    options
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.process = ProcessVariation.(options.processModel)( ...
        options.processOptions);

      this.options = Options( ...
        'control', 'InfNorm', ...
        'tolerance', 1e-2, ...
        'maximalLevel', 20, ...
        'verbose', true, options.surrogateOptions);
    end

    function [ Texp, output ] = interpolate(this, Pdyn, varargin)
      [ processorCount, stepCount ] = size(Pdyn);

      process = this.process;

      switch class(process)
      case 'ProcessVariation.Beta'
        delta = 1e-6;
        distribution = process.transformation.customDistribution;
      otherwise
        assert(false);
      end

      function result = target(rvs)
        rvs = delta + (1 - 2 * delta) * rvs;
        L = transpose(process.evaluate(distribution.icdf(rvs)));
        T = this.solve(Pdyn, Options(varargin{:}, 'L', L));
        result = transpose(reshape(T, processorCount * stepCount, []));
      end

      surrogate = ASGC(@target, this.options, ...
        'inputCount', process.dimensionCount, ...
        'outputCount', processorCount * stepCount);

      Texp = reshape(surrogate.expectation, processorCount, stepCount);

      if nargout < 2, return; end

      output.Tvar = reshape(surrogate.variance, processorCount, stepCount);

      output.surrogate = surrogate;
    end

    function Tdata = sample(this, output, sampleCount)
      Tdata = output.surrogate.sample(sampleCount);
    end

    function Tdata = evaluate(this, output, rvs)
      Tdata = output.surrogate.evaluate(rvs);
    end
  end
end
