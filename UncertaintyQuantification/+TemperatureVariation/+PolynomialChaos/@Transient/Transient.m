classdef Transient < ...
  TemperatureAnalysis.Analytical.Transient & ...
  TemperatureVariation.PolynomialChaos.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@TemperatureAnalysis.Analytical.Transient(options);
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
