classdef Base < handle
  properties (SetAccess = 'private')
    platform
    application
  end

  properties
    %
    % About individual tasks
    %
    taskStartTime
    taskExecutionTime
    taskDynamicPower

    taskASAP
    taskALAP

    taskMobility

    %
    % About the whole application
    %
    applicationExecutionTime
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.platform = options.platform;
      this.application = options.application;

      zero = zeros(1, length(this.application));
      infinity = Inf(1, length(this.application));

      this.taskStartTime = zero;
      this.taskExecutionTime = zero;
      this.taskDynamicPower = zero;

      this.taskASAP = -infinity;
      this.taskALAP = infinity;

      this.taskMobility = zero;

      this.applicationExecutionTime = 0;

      this.configure;
      this.assignTaskASAP;
      this.assignTaskALAP;
    end
  end

  methods (Static, Access = 'protected')
    configure(this)
  end

  methods (Access = 'protected')
    propagateTaskASAP(this, i, time)
    propagateTaskALAP(this, i, time)

    function assignTaskASAP(this)
      for i = this.application.roots
        this.propagateTaskASAP(i, 0);
      end
    end

    function assignTaskALAP(this)
      time = this.computeApplicationASAP();
      for i = this.application.leaves
        this.propagateTaskALAP(i, time);
      end
    end

    function time = computeApplicationASAP(this)
      time = zeros(1, length(this.application));
      for i = this.application.leaves
        time(i) = this.taskASAP(i) + this.taskExecutionTime(i);
      end
      time = max(time);
    end
  end
end
