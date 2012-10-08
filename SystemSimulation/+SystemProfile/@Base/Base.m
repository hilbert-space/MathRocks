classdef Base < handle
  properties (SetAccess = 'private')
    platform
    application
  end

  properties
    %
    % About individual tasks.
    %
    taskStartTime
    taskExecutionTime

    taskASAP
    taskALAP

    taskMobility

    %
    % About the whole application.
    %
    applicationExecutionTime
  end

  methods
    function this = Base(platform, application)
      this.platform = platform;
      this.application = application;

      zero = zeros(1, length(application));
      infinity = ones(1, length(application)) * Inf;

      this.taskStartTime = zero;
      this.taskExecutionTime = zero;

      this.taskASAP = -infinity;
      this.taskALAP = infinity;

      this.taskMobility = zero;

      this.applicationExecutionTime = 0;

      this.assignTaskExecutionTime();
      this.assignTaskASAP();
      this.assignTaskALAP();
    end
  end

  methods (Static, Access = 'protected')
    assignTaskExecutionTime(this)
  end

  methods (Access = 'protected')
    propagateTaskASAP(this, i, time)
    propagateTaskALAP(this, i, time)

    function assignTaskASAP(this)
      for i = this.application.getRoots()
        this.propagateTaskASAP(i, 0);
      end
    end

    function assignTaskALAP(this)
      time = this.computeApplicationASAP();
      for i = this.application.getLeaves()
        this.propagateTaskALAP(i, time);
      end
    end

    function time = computeApplicationASAP(this)
      time = zeros(1, length(this.application));
      for i = this.application.getLeaves()
        time(i) = this.taskASAP(i) + this.taskExecutionTime(i);
      end
      time = max(time);
    end
  end
end
