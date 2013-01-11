classdef Fredholm < KarhunenLoeve.Base
  properties (SetAccess = 'private')
    kernel
  end

  methods
    function this = Fredholm(varargin)
      this = this@KarhunenLoeve.Base(varargin{:});
    end

    function C = calculate(this, s, t)
      C = this.kernel(s, t);
    end
  end

  methods (Access = 'protected')
    [ functions, values ] = construct(this, options)
  end
end
