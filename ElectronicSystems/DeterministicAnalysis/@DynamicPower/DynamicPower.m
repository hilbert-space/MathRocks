classdef DynamicPower < handle
  properties (SetAccess = 'private')
    platform
    application
    samplingInterval
    powerScale
  end

  methods
    function this = DynamicPower(varargin)
      options = Options(varargin{:});

      this.platform = options.platform;
      this.application = options.application;
      this.samplingInterval = options.samplingInterval;
      this.powerScale = options.get('powerScale', 1);
    end
  end
end
