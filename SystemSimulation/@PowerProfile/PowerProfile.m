classdef PowerProfile < handle
  properties (SetAccess = 'protected')
    samplingInterval
    values
  end

  methods
    function this = PowerProfile(schedule, samplingInterval)
      this.samplingInterval = samplingInterval;
      this.values = PowerProfile.compute(schedule, samplingInterval);
    end
  end

  methods (Static)
    function profile = compute(schedule, dt)
      processors = schedule.platform.processors;
      tasks = schedule.application.tasks;

      startTime = schedule.startTime;
      executionTime = schedule.executionTime;

      processorCount = length(schedule.platform);

      stepCount = floor(duration(schedule) / dt);
      profile = zeros(stepCount, processorCount);

      for i = 1:processorCount
        for j = find(schedule.mapping == i)
          s = 1 + floor(startTime(j) / dt);
          e = 1 + floor((startTime(j) + executionTime(j)) / dt);
          e = min([ e, stepCount + 1 ]);
          profile(s:(e - 1), i) = processors{i}.dynamicPower(tasks{j}.type);
        end
      end
    end
  end
end
