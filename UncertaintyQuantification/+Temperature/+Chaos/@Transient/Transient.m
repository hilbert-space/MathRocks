classdef Transient < ...
  Temperature.Analytical.Transient & ...
  Temperature.Chaos.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Transient(options);
      this = this@Temperature.Chaos.Base(options);
    end

    function [ Texp, output ] = compute(this, Pdyn, varargin)
      options = Options(varargin{:});
      [ Texp, output ] = this.expand(Pdyn, options);
    end
  end
end
