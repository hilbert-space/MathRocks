function draw(this, temperatureProfile)
  figure;

  [ processorCount, stepCount ] = size(temperatureProfile);

  time = this.samplingInterval * ((1:stepCount) - 1);

  labels = cell(1, processorCount);

  temperatureProfile = convertKelvinToCelsius(temperatureProfile);

  for i = 1:processorCount
    line(time, temperatureProfile(i, :), 'Color', Color.pick(i));
    labels{i} = sprintf('PE %d', i);
  end

  xlabel('Time, s', 'FontSize', 14);
  ylabel('Temperature, C', 'FontSize', 14);
  xlim([ 0, time(end) ]);
  legend(labels{:});
end
