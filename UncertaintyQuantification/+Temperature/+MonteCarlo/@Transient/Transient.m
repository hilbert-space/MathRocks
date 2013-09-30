classdef Transient < ...
  Temperature.Analytical.Transient & ...
  Temperature.MonteCarlo.Base

  methods
    function this = Transient(varargin)
      options = Options(varargin{:}).clone;

      if ~isempty(options.get('reduceModelOrder', []))
        warning('Monte Carlo: turning off the leakage linearization.');
        options.remove('reduceModelOrder');
      end

      if ~isempty(options.get('linearizeLeakage', []))
        warning('Monte Carlo: turning off the leakage linearization.');
        options.remove('linearizeLeakage');
      end

      this = this@Temperature.Analytical.Transient(options);
      this = this@Temperature.MonteCarlo.Base(options);
    end

    function [ Texp, output ] = compute(this, Pdyn, varargin)
      [ Texp, output ] = this.estimate(Pdyn, varargin{:});
    end

    function string = toString(this)
      string = [ '[ ', ...
        toString@Temperature.Analytical.Transient(this), ', ', ...
        toString@Temperature.MonteCarlo.Base(this), ' ]' ];
    end
  end
end
