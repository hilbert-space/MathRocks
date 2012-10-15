function plot(this, temperatureProfile)
  figure;

  [ processorCount, stepCount ] = size(temperatureProfile);

  time = this.samplingInterval * ((1:stepCount) - 1);

  labels = cell(1, processorCount);

  temperatureProfile = Utils.toCelsius(temperatureProfile);

  for i = 1:processorCount
    line(time, temperatureProfile(i, :), 'Color', Color.pick(i));
    labels{i} = sprintf('PE %d', i);
  end

  Plot.title('Temperature profile');
  Plot.label('Time, s', 'Temperature, C');
  xlim([ 0, time(end) ]);
  legend(labels{:});
end
