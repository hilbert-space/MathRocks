function temperature(T, varargin)
  options = Options(varargin{:});

  stepCount = size(T, 2);

  if options.has('timeLine')
    timeLine = options.timeLine;
    timeLabel = 'Time, s';
  elseif options.has('samplingInterval')
    timeLine = (0:(stepCount - 1)) * options.samplingInterval;
    timeLabel = 'Time, s';
  else
    timeLine = 0:(stepCount - 1);
    timeLabel = 'Time, #';
  end

  if options.get('figure', true), Plot.figure(800, 300); end

  Plot.title('Temperature profile');
  Plot.label(timeLabel, 'Temperature, C');
  if stepCount > 1, Plot.limit(timeLine); end
  Plot.lines(timeLine, Utils.toCelsius(T), options);
end
