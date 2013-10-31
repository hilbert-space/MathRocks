classdef Base < TemperatureVariation.Base
  methods
    function this = Base(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = interpolate(this, Pdyn)
      output = this.surrogate.construct(@(rvs) this.postprocess( ...
        this.computeWithLeakage(Pdyn, this.preprocess(rvs))), numel(Pdyn));
      output.stepCount = size(Pdyn, 2);
    end
  end

  methods (Access = 'protected')
    function surrogate = configure(this, options)
      %
      % NOTE: For now, only one distribution and only beta.
      %
      distributions = this.process.distributions;
      distribution = distributions{1};
      for i = 2:this.process.parameterCount
        assert(distribution == distributions{i});
      end

      switch class(distribution)
      case 'ProbabilityDistribution.Beta'
      otherwise
        assert(false);
      end

      surrogate = Utils.instantiate( ...
         String.join('.', 'Interpolation', options.method), ...
        'inputCount', sum(this.process.dimensions), ...
        'relativeTolerance', 1e-2, ...
        'absoluteTolerance', 1e-3, ...
        'maximalLevel', 10, options);
    end

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
