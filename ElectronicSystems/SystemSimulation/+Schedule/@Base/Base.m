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
      options = Options(varargin{:});

      this.platform = options.platform;
      this.application = options.application;

      taskCount = length(this.application);

      if ~isempty(options.get('priority', []))
        this.priority = options.priority;
      else
        this.priority = NaN(1, taskCount);
      end

      if ~isempty(options.get('mapping', []))
        this.mapping = options.mapping;
      else
        this.mapping = zeros(1, taskCount, 'uint16');
      end

      if ~isempty(options.get('order', []))
        this.order = options.order;
      else
        this.order = zeros(1, taskCount, 'uint16');
      end

      this.startTime = NaN(1, taskCount);
      this.executionTime = NaN(1, taskCount);

      this.construct;
    end

    function count = length(this)
      count = length(this.application);
    end

    function time = duration(this)
      time = max(this.startTime + this.executionTime);
    end
  end

  methods (Abstract, Access = 'protected')
    construct(this)
  end
end
