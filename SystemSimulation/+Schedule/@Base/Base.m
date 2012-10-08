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

      nan = ones(1, length(application)) * NaN;

      this.priority = nan;

      this.mapping = nan;
      this.order = nan;

      this.executionTime = nan;
      this.startTime = nan;

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
