classdef Cool < Scheduler.Base
  properties (SetAccess = 'private')
    timeMapping
    powerMapping

    temperature
    criticalityScale
  end

  methods
    function this = Cool(varargin)
      options = Options(varargin{:});

      this = this@Scheduler.Base(options);

      type = cellfun(@(task) task.type, this.application.tasks);

      processorCount = length(this.platform);
      taskCount = length(this.application);

      this.timeMapping = zeros(taskCount, processorCount);
      this.powerMapping = zeros(taskCount, processorCount);

      for pid = 1:processorCount
        this.powerMapping(:, pid) = ...
          this.platform.processors{pid}.dynamicPower(type);
        this.timeMapping(:, pid) = ...
          this.platform.processors{pid}.executionTime(type);
      end

      this.temperature = options.temperature;
      this.criticalityScale = options.criticalityScale;
    end
  end

  methods (Access = 'protected')
    [ mapping, priority, order, startTime, executionTime ] = ...
      construct(this, mapping, priority, order)
  end
end
