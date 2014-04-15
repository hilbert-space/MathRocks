function power(Pdyn, Pleak, varargin)
  options = Options(varargin{:});

  stepCount = size(Pdyn, 2);

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

  Plot.title('Power profile');
  Plot.label(timeLabel, 'Power, W');
  if stepCount > 1, Plot.limit(timeLine); end
  Plot.lines(timeLine, Pdyn, options);

  if isempty(Pleak), return; end

  Plot.lines(timeLine, Pleak, options, 'auxiliary', true);
end
