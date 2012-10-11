classdef Base < handle
  properties (SetAccess = 'private')
    platform
    application
  end

  properties (SetAccess = 'protected')
    priority

    mapping
    order

    startTime
    executionTime
  end

  methods
    function this = Base(platform, application)
      this.platform = platform;
      this.application = application;

      count = length(application);

      this.priority = ones(1, count) * NaN;

      this.mapping = uint16(zeros(1, count));
      this.order   = uint16(zeros(1, count));

      this.executionTime = ones(1, count) * NaN;
      this.startTime     = ones(1, count) * NaN;

      this.perform();
    end

    function adjustExecutionTime(this, executionTime)
      this.executionTime = executionTime;
      this.startTime(:) = NaN;

      this.perform();
    end

    function count = length(this)
      count = length(this.application);
    end

    function time = duration(this)
      time = max(this.startTime + this.executionTime);
    end
  end

  methods (Static, Access = 'protected')
    perform(this)
  end
end
