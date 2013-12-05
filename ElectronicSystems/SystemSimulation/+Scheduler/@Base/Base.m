classdef Base < handle
  properties (SetAccess = 'private')
    platform
    application
  end

  methods
    function this = Base(varargin)
      options = Options(varargin{:});
      this.platform = options.platform;
      this.application = options.application;
    end

    function output = compute(this, mapping, priority, order)
      taskCount = length(this.application);

      if nargin < 2 || isempty(mapping)
        mapping = zeros(1, taskCount);
      end

      if nargin < 3 || isempty(priority)
        profile = SystemProfile.Average( ...
          'platform', this.platform, ...
          'application', this.application);
        priority = profile.taskMobility;
      end

      if nargin < 4 || isempty(order)
        order = zeros(1, taskCount);
      end

      [ mapping, priority, order, startTime, executionTime ] = ...
        this.construct(mapping, priority, order);

      output = [ mapping; priority; order; startTime; executionTime ];
    end

    function schedule = decode(~, output)
      schedule = struct;
      schedule.mapping = output(1, :);
      schedule.priority = output(2, :);
      schedule.order = output(3, :);
      schedule.startTime = output(4, :);
      schedule.executionTime = output(5, :);
    end
  end

  methods (Abstract, Access = 'protected')
    [ mapping, priority, order, startTime, executionTime ] = ...
      construct(this, mapping, priority, order);
  end
end
