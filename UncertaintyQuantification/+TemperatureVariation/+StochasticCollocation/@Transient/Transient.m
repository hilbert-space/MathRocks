classdef Transient < ...
  Temperature.Analytical.Transient & ...
  TemperatureVariation.StochasticCollocation.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Transient(options);
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
