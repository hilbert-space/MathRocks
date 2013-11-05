classdef Transient < Temperature.Numerical.Base
  methods
    function this = Transient(varargin)
      this = this@Temperature.Numerical.Base(varargin{:});
    end
  end
end
