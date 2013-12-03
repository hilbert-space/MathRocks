classdef DynamicSteadyState < Temperature.Analytical.Base
  properties (SetAccess = 'protected')
    algorithm
    maximalTemperature
    convergenceMetric
    convergenceTolerance
    iterationLimit
  end

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Base(options);

      this.algorithm = options.get('algorithm', 1);
      this.maximalTemperature = options.get( ...
        'maximalTemperature', Utils.toKelvin(450));
      this.convergenceMetric = options.get('convergenceMetric', 'NRMSE');
      this.convergenceTolerance = options.get('convergenceTolerance', 0.01);
      this.iterationLimit = options.get('iterationLimit', 20);
    end
  end
end
