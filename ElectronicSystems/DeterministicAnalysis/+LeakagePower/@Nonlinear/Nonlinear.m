classdef Nonlinear < LeakagePower.Base
  methods
    function this = Nonlinear(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function surrogate = construct(~, options)
      surrogate = Fitting(options);
    end
  end
end
