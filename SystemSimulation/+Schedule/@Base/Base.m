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
    function this = Base(varargin)
      if isa(varargin{1}, 'Platform')
        assert(isa(varargin{2}, 'Application'));

        this.platform = varargin{1};
        this.application = varargin{2};

        count = length(this.application);

        this.priority = NaN(1, count);

        this.mapping = zeros(1, count, 'uint16');
        this.order = zeros(1, count, 'uint16');

        this.startTime = NaN(1, count);
        this.executionTime = NaN(1, count);

        options = Options(varargin{3:end});
      elseif isa(varargin{1}, 'Schedule.Base')
        schedule = varargin{1};

        this.platform = schedule.platform;
        this.application = schedule.application;

        count = length(this.application);

        this.priority = schedule.priority;

        this.mapping = schedule.mapping;
        this.order = schedule.order;

        this.startTime = NaN(1, count);
        this.executionTime = NaN(1, count);

        options = Options(varargin{2:end});
      else
        assert(false);
      end

      if options.has('priority')
        this.priority = options.priority;
      end

      if options.has('mapping')
        this.mapping = options.mapping;
      end

      if options.has('order')
        this.order = options.order;
      end

      if options.has('executionTime')
        this.executionTime = options.executionTime;
      end

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
