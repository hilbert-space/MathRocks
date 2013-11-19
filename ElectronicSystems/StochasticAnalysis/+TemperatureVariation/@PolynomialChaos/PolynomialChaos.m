classdef PolynomialChaos < TemperatureVariation.Base
  methods
    function this = PolynomialChaos(varargin)
      this = this@TemperatureVariation.Base(varargin{:});
    end

    function output = compute(this, Pdyn)
      output = this.surrogate.construct( ...
        @(rvs) this.surve(Pdyn, rvs));
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

      surrogate = PolynomialChaos( ...
        'inputCount', sum(this.process.dimensions), ...
        'distribution', distribution, options);
    end

    function T = surve(this, Pdyn, rvs)
      sampleCount = size(rvs, 1);

      parameters = this.process.partition(rvs);
      parameters = this.process.evaluate(parameters);
      parameters = this.process.assign(parameters);

      T = this.temperature.computeWithLeakage(Pdyn, parameters);
      T = transpose(reshape(T, [], sampleCount));
    end
  end
end
