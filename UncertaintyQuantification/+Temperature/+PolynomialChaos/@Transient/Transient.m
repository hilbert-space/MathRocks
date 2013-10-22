classdef Transient < ...
  Temperature.Analytical.Transient & ...
  Temperature.PolynomialChaos.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Transient(options);
      this = this@Temperature.PolynomialChaos.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.expand(varargin{:});
    end

    function plot(this, output)
      this.surrogate.plot(output);
    end
  end
end
