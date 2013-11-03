classdef Transient < TemperatureAnalysis.Analytical.Base
  methods
    function this = Transient(varargin)
      this = this@TemperatureAnalysis.Analytical.Base(varargin{:});
    end
  end
end
