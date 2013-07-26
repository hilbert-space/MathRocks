classdef DynamicSteadyState < Temperature.Analytical.Base
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
      if ~isa(this.leakage, 'struct')
        [ T, output ] = feval([ algorithm, 'WithLeakage' ], this, Pdyn, options);
      else
        [ T, output ] = feval([ algorithm, 'WithLinearLeakage' ], this, Pdyn, options);
      end
    end
  end
end
