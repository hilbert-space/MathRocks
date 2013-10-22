classdef DynamicSteadyState < ...
  Temperature.Analytical.DynamicSteadyState & ...
  Temperature.PolynomialChaos.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.DynamicSteadyState(options);
      this = this@Temperature.PolynomialChaos.Base(options);
    end

    function output = compute(this, varargin)
      output = this.expand(varargin{:});
    end

    function plot(this, output)
      this.surrogate.plot(output);
    end
  end
end
