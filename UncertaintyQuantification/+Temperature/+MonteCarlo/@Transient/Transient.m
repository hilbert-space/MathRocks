classdef Transient < ...
  Temperature.Analytical.Transient & ...
  Temperature.MonteCarlo.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:});
      this = this@Temperature.Analytical.Transient(options, ...
        'reduceModelOrder', [], 'linearizeLeakage', []);
      this = this@Temperature.MonteCarlo.Base(options);
    end

    function [ Texp, output ] = compute(this, varargin)
      [ Texp, output ] = this.estimate(varargin{:});
    end

    function string = toString(this)
      string = [ ...
        toString@Temperature.Analytical.Transient(this), ...
        toString@Temperature.MonteCarlo.Base(this) ];
    end
  end
end
