classdef Transient < ...
  TemperatureAnalysis.Analytical.Transient & ...
  TemperatureVariation.MonteCarlo.Base

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

      this = this@TemperatureAnalysis.Analytical.Transient(options);
      this = this@TemperatureVariation.MonteCarlo.Base(options);
    end

    function output = compute(this, Pdyn, varargin)
      output = this.estimate(Pdyn, varargin{:});
    end

    function string = toString(this)
      string = [ '[ ', ...
        toString@TemperatureAnalysis.Analytical.Transient(this), ', ', ...
        toString@TemperatureVariation.MonteCarlo.Base(this), ' ]' ];
    end
  end
end
