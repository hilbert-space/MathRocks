classdef Average < SystemProfile.Base
  methods
    function this = Average(varargin)
      this = this@SystemProfile.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function assignTaskExecutionTime(this)
      processors = this.platform.processors;
      tasks = this.application.tasks;

      processorCount = length(processors);
      taskCount = length(tasks);

      %
      % Calculate average execution times of the tasks.
      %
      for i = 1:taskCount
        total = 0;
        for j = 1:processorCount
          total = total + processors{j}.executionTime(tasks{i}.type);
        end
        this.taskExecutionTime(i) = total / processorCount;
      end
    end
  end
end
