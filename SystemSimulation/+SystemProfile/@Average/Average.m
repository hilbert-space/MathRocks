classdef Average < SystemProfile.Base
  methods
    function this = Average(varargin)
      this = this@SystemProfile.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function assignTaskExecutionTime(this)
      platform = this.platform;
      application = this.application;

      processorCount = length(platform);
      taskCount = length(application);

      %
      % Calculate average execution times of the tasks.
      %
      for i = 1:taskCount
        total = 0;
        for j = 1:processorCount
          total = total + platform{j}.executionTime(application{i}.type);
        end
        this.taskExecutionTime(i) = total / processorCount;
      end
    end
  end
end
