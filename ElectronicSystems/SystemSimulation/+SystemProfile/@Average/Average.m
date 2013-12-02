classdef Average < SystemProfile.Base
  methods
    function this = Average(varargin)
      this = this@SystemProfile.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function configure(this)
      processors = this.platform.processors;
      tasks = this.application.tasks;

      processorCount = length(processors);
      taskCount = length(tasks);

      %
      % Calculate average execution times of the tasks.
      %
      for i = 1:taskCount
        executionTime = 0;
        dynamicPower = 0;
        for j = 1:processorCount
          executionTime = executionTime + ...
            processors{j}.executionTime(tasks{i}.type);
          dynamicPower = dynamicPower + ...
            processors{j}.dynamicPower(tasks{i}.type);
        end
        this.taskExecutionTime(i) = executionTime / processorCount;
        this.taskDynamicPower(i) = dynamicPower / processorCount;
      end
    end
  end
end
