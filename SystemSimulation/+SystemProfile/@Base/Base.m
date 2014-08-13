classdef Base < handle
  properties (SetAccess = 'private')
    platform
    application
  end

  properties (SetAccess = 'protected')
    %
    % About individual tasks
    %
    taskStartTime
    taskExecutionTime
    taskDynamicPower

    taskASAP
    taskALAP

    taskMobility
    taskStaticCriticality

    %
    % About the whole application
    %
    applicationASAP
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});

      this.platform = options.platform;
      this.application = options.application;

      taskCount = length(this.application);

      zero = zeros(1, taskCount);
      infinity = Inf(1, taskCount);

      this.taskStartTime = zero;
      this.taskExecutionTime = zero;
      this.taskDynamicPower = zero;

      this.taskASAP = -infinity;
      this.taskALAP = infinity;

      this.taskMobility = zero;

      %
      % NOTE: Not nice, but the order matters!
      %
      this.configure;
      this.assignTaskASAP;
      this.assignApplicationASAP;
      this.assignTaskALAP;

      %
      % Static criticality
      %
      % Reference:
      %
      % Y. Xie et al. "Temperature-aware task allocation and scheduling
      % for embedded MPSoC design." Journal of VLSI Signal Processing,
      % 45(3):177–189, 2006.
      %
      this.taskStaticCriticality = zeros(1, taskCount);
      for i = 1:taskCount
        this.taskStaticCriticality(i) = ...
          this.applicationASAP - this.taskASAP(i);
      end
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

    function assignApplicationASAP(this)
      time = zeros(1, length(this.application));
      for i = this.application.leaves
        time(i) = this.taskASAP(i) + this.taskExecutionTime(i);
      end
      this.applicationASAP = max(time);
    end

    function assignTaskALAP(this)
      for i = this.application.leaves
        this.propagateTaskALAP(i, this.applicationASAP);
      end
    end
  end
end
