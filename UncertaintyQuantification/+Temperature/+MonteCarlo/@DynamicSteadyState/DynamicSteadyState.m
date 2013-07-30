classdef DynamicSteadyState < ...
  Temperature.Analytical.DynamicSteadyState & ...
  Temperature.MonteCarlo.Base

  methods
    function this = DynamicSteadyState(varargin)
      options = Options(varargin{:});

      if ~isempty(options.get('reduceModelOrder', []))
        warning('Monte Carlo: turning off the model order reduction.');
        options.reduceModelOrder = [];
      end

      if ~isempty(options.get('reduceModelOrder', []))
        warning('Monte Carlo: turning off the leakage linearization.');
        options.linearizeLeakage = [];
      end

      this = this@Temperature.Analytical.DynamicSteadyState(options);
      this = this@Temperature.MonteCarlo.Base(options);
    end

    function [ Texp, output ] = compute(this, Pdyn, varargin)
      options = Options(varargin{:});

      if options.get('version', Inf) >= 3
        warning('Monte Carlo: switching to the second version of the algorithm.');
        options.version = 2;
      end

      [ Texp, output ] = this.estimate(Pdyn, options);
    end

    function string = toString(this)
      string = [ ...
        toString@Temperature.Analytical.DynamicSteadyState(this), ...
        toString@Temperature.MonteCarlo.Base(this) ];
    end
  end
end
