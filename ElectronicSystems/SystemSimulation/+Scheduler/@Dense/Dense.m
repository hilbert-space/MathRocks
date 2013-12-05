classdef Dense < Scheduler.Base
  methods
    function this = Dense(varargin)
      this = this@Scheduler.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ mapping, priority, order, startTime, executionTime ] = ...
      construct(this, mapping, priority, order)
  end
end
