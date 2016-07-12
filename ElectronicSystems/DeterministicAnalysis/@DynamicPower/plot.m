function plot(this, profile, varargin)
  Plot.power(profile, [], 'samplingInterval', ...
    this.samplingInterval, varargin{:});
end
