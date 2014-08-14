function plot(this, output)
  processors = this.platform.processors;
  tasks = this.application.tasks;

  processorCount = length(processors);
  taskCount = length(tasks);

  output = this.decode(output);

  Plot.figure;
  Plot.title('Schedule');
  Plot.label('Time, s');
  set(gca,'YTick', [], 'YTickLabel', []);

  last = max(output.startTime + output.executionTime);

  taskPower = zeros(taskCount, 1);
  for i = 1:taskCount
    taskPower(i) = processors{output.mapping(i)}.dynamicPower(tasks{i}.type);
  end
  taskPower = taskPower ./ max(taskPower);

  processorNames = {};

  maxHeight = 0.8;
  for i = 1:processorCount
    y0 = i;

    ids = find(output.mapping == i);
    [~, I] = sort(output.order(ids));
    ids = ids(I);

    x = [0];
    y = [y0];
    for j = ids
      startTime = output.startTime(j);
      executionTime = output.executionTime(j);

      height = maxHeight;
      height = height * taskPower(j);

      x(end + 1) = startTime;
      y(end + 1) = y0;

      x(end + 1) = startTime;
      y(end + 1) = y0 + height;

      x(end + 1) = startTime + executionTime;
      y(end + 1) = y0 + height;

      x(end + 1) = startTime + executionTime;
      y(end + 1) = y0;

      text(startTime + 0.2 * executionTime, y0 + 0.3 * maxHeight, ...
        ['T', num2str(j)]);
    end

    x(end + 1) = last;
    y(end + 1) = y0;

    x(end + 1) = 0;
    y(end + 1) = y0;

    line(x, y, 'Color', Color.pick(i));

    processorNames{end + 1} = ['PE', num2str(i)];
  end

  set(gca, 'YTickLabel', processorNames);
  set(gca, 'YTick', (1:processorCount) + maxHeight / 2);
  set(gca, 'XLim', [0 last]);
end
