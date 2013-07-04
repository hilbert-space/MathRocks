classdef Transient < ...
  Temperature.Analytical.Transient & ...
  Temperature.Chaos.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Transient( ...
        options.temperatureOptions);
      this = this@Temperature.Chaos.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.expand(varargin{:});
    end
  end
end
