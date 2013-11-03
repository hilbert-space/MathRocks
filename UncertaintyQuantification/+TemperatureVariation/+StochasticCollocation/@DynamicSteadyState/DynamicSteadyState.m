classdef DynamicSteadyState < ...
  TemperatureAnalysis.Analytical.DynamicSteadyState & ...
  TemperatureVariation.StochasticCollocation.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@TemperatureAnalysis.Analytical.DynamicSteadyState(options);
      this = this@TemperatureVariation.StochasticCollocation.Base(options);
    end

    function output = compute(this, varargin)
      output = this.interpolate(varargin{:});
    end

    function plot(this, varargin)
      if this.surrogate.inputCount > 3, return; end
      this.surrogate.plot(varargin{:});
    end
  end
end
