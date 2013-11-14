classdef StochasticCollocation < TemperatureVariation.Base
  methods
    function this = StochasticCollocation(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = compute(this, Pdyn)
      output = this.surrogate.construct( ...
        @(rvs) this.surve(Pdyn, rvs), numel(Pdyn));
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
         String.join('.', 'StochasticCollocation', options.method), ...
        'inputCount', sum(this.process.dimensions), ...
        'relativeTolerance', 1e-2, ...
        'absoluteTolerance', 1e-3, ...
        'maximalLevel', 10, options);
    end

    function T = surve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      rvs(rvs == 0) = sqrt(eps);
      rvs(rvs == 1) = 1 - sqrt(eps);
      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters, true); % uniform
      parameters = this.process.assign(parameters);

      T =  this.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
