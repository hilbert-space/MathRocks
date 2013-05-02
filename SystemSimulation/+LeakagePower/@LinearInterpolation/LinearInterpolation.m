classdef LinearInterpolation < LeakagePower.Base
  methods
    function this = LinearInterpolation(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end

    function P = evaluate(this, L, T)
      output = this.output;
      L = (L - output.expectation(1)) / output.deviation(1);
      T = (T - output.expectation(2)) / output.deviation(2);
      P = output.powerScale * feval(output.fitobject, L, T);
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
