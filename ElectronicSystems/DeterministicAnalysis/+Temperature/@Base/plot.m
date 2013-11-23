function plot(this, profile, varargin)
  Plot.temperature(profile, [], 'samplingInterval', ...
    this.samplingInterval, varargin{:});
end
