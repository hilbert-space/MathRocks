classdef Dense < Scheduler.Base
  properties (SetAccess = 'private')
    timeMapping
    taskMobility
  end

  methods
    function this = Dense(varargin)
      this = this@Scheduler.Base(varargin{:});

      type = cellfun(@(task) task.type, this.application.tasks);

      processorCount = length(this.platform);
      taskCount = length(this.application);

      this.timeMapping = zeros(taskCount, processorCount);

      for pid = 1:processorCount
        this.timeMapping(:, pid) = ...
          this.platform.processors{pid}.executionTime(type);
      end
    end
  end

  methods (Access = 'protected')
    [ mapping, priority, order, startTime, executionTime ] = ...
      construct(this, varargin)
  end
end
