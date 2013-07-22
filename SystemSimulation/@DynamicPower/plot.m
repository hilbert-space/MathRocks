function plot(this, powerProfile)
  Plot.powerTemperature(powerProfile, [], [], ...
    'samplingInterval', this.samplingInterval);
end
