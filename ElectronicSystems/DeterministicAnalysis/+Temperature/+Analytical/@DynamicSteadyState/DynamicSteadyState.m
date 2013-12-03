classdef DynamicSteadyState < Temperature.Analytical.Base
  properties (SetAccess = 'protected')
    algorithm
    maximalTemperature
    errorMetric
    errorThreshold
    iterationLimit
  end

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Base(options);

      this.algorithm = options.get('algorithm', 1);
      this.maximalTemperature = options.get( ...
        'maximalTemperature', Utils.toKelvin(450));
      this.errorMetric = options.get('errorMetric', 'NRMSE');
      this.errorThreshold = options.get('errorThreshold', 0.01);
      this.iterationLimit = options.get('iterationLimit', 20);
    end
  end
end
