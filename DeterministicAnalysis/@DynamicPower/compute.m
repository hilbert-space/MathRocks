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
  taskCount = length(tasks);
  stepCount = floor(duration / dt);

  power = zeros(processorCount, stepCount);

  for i = 1:taskCount
    j = mapping(i);
    s = 1 + floor(startTime(i) / dt);
    f = min(stepCount, floor((startTime(i) + executionTime(i)) / dt));
    power(j, s:f) = processors{j}.dynamicPower(tasks{i}.type);
  end

  power = this.powerScale * power;
end
