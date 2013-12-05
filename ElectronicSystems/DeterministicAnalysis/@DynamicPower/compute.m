function power = compute(this, schedule)
  processors = this.platform.processors;
  tasks = this.application.tasks;

  %
  % NOTE: See Schedule.Base for the encoding.
  %
  mapping = schedule(1, :);
  startTime = schedule(4, :);
  executionTime = schedule(5, :);

  duration = max(startTime + executionTime);
  dt = this.samplingInterval;

  processorCount = length(processors);
  stepCount = floor(duration / dt);

  power = zeros(processorCount, stepCount);

  for i = 1:processorCount
    for j = find(mapping == i)
      s = 1 + floor(startTime(j) / dt);
      e = min(stepCount, floor((startTime(j) + executionTime(j)) / dt));
      power(i, s:e) = processors{i}.dynamicPower(tasks{j}.type);
    end
  end

  power = this.powerScale * power;
end
