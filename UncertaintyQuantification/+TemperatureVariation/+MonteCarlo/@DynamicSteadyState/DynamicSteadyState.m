classdef DynamicSteadyState < ...
  TemperatureAnalysis.Analytical.DynamicSteadyState & ...
  TemperatureVariation.MonteCarlo.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:}).clone;

      if ~isempty(options.get('reduceModelOrder', []))
        warning('Monte Carlo: turning off the model order reduction.');
        options.remove('reduceModelOrder');
      end

      if ~isempty(options.get('linearizeLeakage', []))
        warning('Monte Carlo: turning off the leakage linearization.');
        options.remove('linearizeLeakage');
      end

      if options.get('algorithmVersion', 1) >= 3
        warning('Monte Carlo: switching the second version of the algorithm.');
        options.algorithmVersion = 2;
      end

      this = this@TemperatureAnalysis.Analytical.DynamicSteadyState(options);
      this = this@TemperatureVariation.MonteCarlo.Base(options);
    end

    function output = compute(this, Pdyn, varargin)
      output = this.estimate(Pdyn, varargin{:});
    end

    function string = toString(this)
      string = [ '[ ', ...
        toString@Temperature.Analytical.DynamicSteadyState(this), ', ', ...
        toString@Temperature.MonteCarlo.Base(this), ' ]' ];
    end
  end
end
