function power(Pdyn, Pleak, varargin)
  options = Options(varargin{:});

  if options.has('timeLine')
    timeLine = options.timeLine;
    timeLabel = 'Time, s';
  elseif options.has('samplingInterval')
    timeLine = (0:(size(Pdyn, 2) - 1)) * options.samplingInterval;
    timeLabel = 'Time, s';
  else
    timeLine = 0:(size(Pdyn, 2) - 1);
    timeLabel = 'Time, #';
  end

  if options.get('figure', true), Plot.figure(800, 400); end

  Plot.title('Power profile');
  Plot.label(timeLabel, 'Power, W');
  Plot.limit(timeLine);
  Plot.lines(timeLine, Pdyn, options);

  if isempty(Pleak), return; end

  Plot.lines(timeLine, Pleak, options, 'auxiliary', true);
end
