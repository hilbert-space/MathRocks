classdef StochasticCollocation < TemperatureVariation.Base
  properties (SetAccess = 'protected')
    boundedness
  end

  methods
    function this = StochasticCollocation(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = compute(this, Pdyn)
      output = this.surrogate.construct( ...
        @(rvs) this.serve(Pdyn, this.preprocess(rvs)), numel(Pdyn));
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

      [ ~, this.boundedness ] = distribution.isBounded;

      surrogate = Utils.instantiate( ...
         String.join('.', 'StochasticCollocation', options.method), ...
        'inputCount', sum(this.process.dimensions), ...
        'relativeTolerance', 1e-2, ...
        'absoluteTolerance', 1e-3, ...
        'maximalLevel', 10, options);
    end

    function T = serve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters, true); % uniform
      parameters = this.process.assign(parameters);

      T =  this.temperature.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end

    function rvs = preprocess(this, rvs)
      if ~this.boundedness(1)
        rvs(rvs == 0) = sqrt(eps);
      end
      if ~this.boundedness(2)
        rvs(rvs == 1) = 1 - sqrt(eps);
      end
    end
  end
end
