classdef DynamicSteadyState < ...
  Temperature.Analytical.DynamicSteadyState & ...
  Temperature.MonteCarlo.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.DynamicSteadyState(options);
      this = this@Temperature.MonteCarlo.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.estimate(varargin{:});
    end

    function string = toString(this)
      string = [ ...
        toString@Temperature.Analytical.DynamicSteadyState(this), ...
        toString@Temperature.MonteCarlo.Base(this) ];
    end
  end
end
