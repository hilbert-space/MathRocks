function temperature(T, varargin)
  options = Options(varargin{:});

  if options.has('timeLine')
    timeLine = options.timeLine;
    timeLabel = 'Time, s';
  elseif options.has('samplingInterval')
    timeLine = (0:(size(T, 2) - 1)) * options.samplingInterval;
    timeLabel = 'Time, s';
  else
    timeLine = 0:(size(T, 2) - 1);
    timeLabel = 'Time, #';
  end

  if options.get('figure', true), Plot.figure(800, 300); end

  Plot.title('Temperature profile');
  Plot.label(timeLabel, 'Temperature, C');
  Plot.limit(timeLine);
  Plot.lines(timeLine, Utils.toCelsius(T), options);
end
