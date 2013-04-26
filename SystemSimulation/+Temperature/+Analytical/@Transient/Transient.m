classdef Transient < Temperature.Analytical.Base
  methods
    function this = Transient(varargin)
      this = this@Temperature.Analytical.Base(varargin{:});
    end
  end
end
