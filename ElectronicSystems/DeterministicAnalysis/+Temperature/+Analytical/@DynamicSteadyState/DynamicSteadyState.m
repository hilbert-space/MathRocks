classdef DynamicSteadyState < Temperature.Analytical.Base
  properties (SetAccess = 'protected')
    iterationLimit
    temperatureLimit
    convergenceTolerance
    algorithmVersion
  end

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Base(options);

      this.iterationLimit = ...
        options.get('iterationLimit', 20);
      this.temperatureLimit = ...
        options.get('temperatureLimit', Utils.toKelvin(1e3));
      this.convergenceTolerance = ...
        options.get('convergenceTolerance', 0.5);
      this.algorithmVersion = ...
        options.get('algorithmVersion', 1);
    end
  end
end
