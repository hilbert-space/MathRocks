classdef DynamicPower < handle
  properties (SetAccess = 'protected')
    samplingInterval
  end

  methods
    function this = DynamicPower(samplingInterval)
      this.samplingInterval = samplingInterval;
    end

    function profile = compute(this, schedule)
      processors = schedule.platform.processors;
      tasks = schedule.application.tasks;

      startTime = schedule.startTime;
      executionTime = schedule.executionTime;

      processorCount = length(schedule.platform);

      dt = this.samplingInterval;

      stepCount = floor(duration(schedule) / dt);
      profile = zeros(processorCount, stepCount);

      for i = 1:processorCount
        for j = find(schedule.mapping == i)
          s = 1 + floor(startTime(j) / dt);
          e = min(stepCount, floor((startTime(j) + executionTime(j)) / dt));
          profile(i, s:e) = processors{i}.dynamicPower(tasks{j}.type);
        end
      end
    end
  end
end
