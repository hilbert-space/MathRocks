classdef Base < handle
  properties (SetAccess = 'protected')
    process
    distribution
    surrogate
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.process = ProcessVariation(options.processOptions);

      %
      % NOTE: For now, only one distribution and only beta.
      %
      distributions = this.process.distributions;
      this.distribution = distributions{1};
      for i = 2:this.process.parameterCount
        assert(this.distribution == distributions{i});
      end

      switch class(this.distribution)
      case 'ProbabilityDistribution.Beta'
      otherwise
        assert(false);
      end

      this.surrogate = ASGC( ...
        'inputCount', sum(this.process.dimensions), ...
        'control', 'InfNorm', ...
        'tolerance', 1e-2, ...
        'maximalLevel', 20, ...
        'verbose', true, ...
        options.surrogateOptions);
    end

    function [ Texp, output ] = interpolate(this, Pdyn)
      surrogateOutput = this.surrogate.construct(@(rvs) this.postprocess( ...
        this.computeWithLeakage(Pdyn, this.preprocess(rvs))), numel(Pdyn));

      Texp = reshape(surrogateOutput.expectation, this.processorCount, []);

      if nargout < 2, return; end

      output.Tvar = reshape(surrogateOutput.variance, this.processorCount, []);
      output.surrogateOutput = surrogateOutput;
      output.stepCount = size(Pdyn, 2);
    end

    function Tdata = sample(this, output, varargin)
      Tdata = reshape(this.surrogate.sample( ...
        output.surrogateOutput, varargin{:}), ...
        [], this.processorCount, output.stepCount);
    end

    function Tdata = evaluate(this, output, varargin)
      Tdata = reshape(this.surrogate.evaluate( ...
        output.surrogateOutput, varargin{:}), ...
        [], this.processorCount, output.stepCount);
    end

    function stats = computeStatistics(~, output)
      stats.functionEvaluations = output.surrogateOutput.nodeCount;
    end
  end

  methods (Access = 'protected')
    function parameters = preprocess(this, rvs)
      rvs(rvs == 0) = sqrt(eps);
      rvs(rvs == 1) = 1 - sqrt(eps);
      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters, true); % uniform
      parameters = cellfun(@transpose, parameters, 'UniformOutput', false);
      parameters = this.process.assign(parameters);
    end

    function T = postprocess(~, T)
      sampleCount = size(T, 3);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
