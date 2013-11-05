classdef DynamicSteadyState < ...
  Temperature.Analytical.DynamicSteadyState & ...
  TemperatureVariation.PolynomialChaos.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.DynamicSteadyState(options);
      this = this@TemperatureVariation.PolynomialChaos.Base(options);
    end

    function output = compute(this, varargin)
      output = this.expand(varargin{:});
    end

    function plot(this, varargin)
      this.surrogate.plot(varargin{:});
    end
  end
end
