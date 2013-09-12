function plot(this, powerProfile, varargin)
  Plot.powerTemperature(powerProfile, [], [], ...
    'samplingInterval', this.samplingInterval, varargin{:});
end
