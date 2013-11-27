classdef Dense < Schedule.Base
  methods
    function this = Dense(varargin)
      this = this@Schedule.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    construct(this)
  end
end
