function powerTemperature(Pdyn, Pleak, T, varargin)
  options = Options(varargin{:});

  [ processorCount, stepCount ] = size(Pdyn);

  if options.has('time')
    time = options.time;
    timeLabel = 'Time, s';
  elseif options.has('samplingInterval')
    time = (0:(stepCount - 1)) * options.samplingInterval;
    timeLabel = 'Time, s';
  else
    time = 0:(stepCount - 1);
    timeLabel = 'Time, #';
  end

  T = Utils.toCelsius(T);

  figure;

  if ~isempty(T), subplot(2, 1, 1); end

  Plot.title('Power profile');
  Plot.label(timeLabel, 'Power, W');
  Plot.limit(time);
  for i = 1:processorCount
    color = Color.pick(i);
    line(time, Pdyn(i, :), 'Color', color);
    if isempty(Pleak), continue; end
    line(time, Pleak(i, :), 'Color', color, 'LineStyle', '--');
  end

  if isempty(T), return; end

  subplot(2, 1, 2);

  Plot.title('Temperature profile');
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
  for i = 1:processorCount
    line(time, T(i, :), 'Color', Color.pick(i));
  end
end
