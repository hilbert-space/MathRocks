classdef DynamicSteadyState < ...
  Temperature.Analytical.DynamicSteadyState & ...
  Temperature.ASGC.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.DynamicSteadyState( ...
        options.temperatureOptions);
      this = this@Temperature.ASGC.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.interpolate(varargin{:});
    end
  end
end
