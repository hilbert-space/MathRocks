classdef DynamicSteadyState < Temperature.Analytical.Base
  methods
    function this = DynamicSteadyState(varargin)
      this = this@Temperature.Analytical.Base(varargin{:});
    end
  end
end
