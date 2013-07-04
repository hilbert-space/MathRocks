classdef Transient < ...
  Temperature.Numerical.Transient & ...
  Temperature.MonteCarlo.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Numerical.Transient( ...
        options.temperatureOptions);
      this = this@Temperature.MonteCarlo.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.estimate(varargin{:});
    end

    function string = toString(this)
      string = [ ...
        toString@Temperature.Numerical.Transient(this), ...
        toString@Temperature.MonteCarlo.Base(this) ];
    end
  end
end
