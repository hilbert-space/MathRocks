classdef DynamicSteadyState < Temperature.Analytical.Base
  properties (Constant)
    iterationLimit = 20;
    temperatureLimit = Utils.toKelvin(1e3);
    tolerance = 0.5;
  end

  methods
    function this = DynamicSteadyState(varargin)
      this = this@Temperature.Analytical.Base(varargin{:});
    end

    function T = computeWithoutLeakage(this, Pdyn, options)
      algorithm = options.get('algorithm', 'condensedEquation');
      T = feval([ algorithm, 'WithoutLeakage' ], this, Pdyn, options);
    end

    function [ T, output ] = computeWithLeakage(this, Pdyn, options)
      algorithm = options.get('algorithm', 'condensedEquation');

      if isa(this.leakage, 'struct')
        suffix = 'WithLinearLeakage';
      elseif options.get('passiveLeakage', false)
        suffix = 'WithPassiveLeakage';
      else
        suffix = 'WithLeakage';
      end

      [ T, output ] = feval([ algorithm, suffix ], this, Pdyn, options);
    end
  end
end
