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
    function this = Base(platform, application, varargin)
      options = Options(varargin{:});

      this.platform = platform;
      this.application = application;

      count = length(application);

      this.priority = ...
        options.get('priority', @() NaN(1, count));

      this.mapping = ...
        options.get('mapping', @() zeros(1, count, 'uint16'));
      this.order = ...
        options.get('order', @() zeros(1, count, 'uint16'));

      this.executionTime = NaN(1, count);
      this.startTime = NaN(1, count);

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