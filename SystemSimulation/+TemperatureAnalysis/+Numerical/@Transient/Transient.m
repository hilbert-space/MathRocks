classdef Transient < TemperatureAnalysis.Numerical.Base
  methods
    function this = Transient(varargin)
      this = this@TemperatureAnalysis.Numerical.Base(varargin{:});
    end
  end
end
