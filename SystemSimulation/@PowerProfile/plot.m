function plot(this, powerProfile)
  figure;

  [ processorCount, stepCount ] = size(powerProfile);

  time = this.samplingInterval * ((1:stepCount) - 1);

  labels = cell(1, processorCount);

  for i = 1:processorCount
    line(time, powerProfile(i, :), 'Color', Color.pick(i));
    labels{i} = sprintf('PE %d', i);
  end

  Plot.title('Power profile');
  Plot.label('Time, s', 'Dynamic power, W');
  xlim([ 0, time(end) ]);
  legend(labels{:});
end
