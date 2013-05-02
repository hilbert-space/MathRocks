function plotPowerTemperature(Pdyn, Pleak, T, samplingInterval)
  if nargin < 4, samplingInterval = 1; end

  [ processorCount, stepCount ] = size(Pdyn);

  T = Utils.toCelsius(T);
  time = samplingInterval * (1:stepCount);

  figure;

  if ~isempty(T), subplot(2, 1, 1); end

  Plot.title('Power profile');
  Plot.label('Time, s', 'Power, W');
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
