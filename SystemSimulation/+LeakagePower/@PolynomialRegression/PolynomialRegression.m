classdef PolynomialRegression < LeakagePower.Base
  methods
    function this = PolynomialRegression(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end

    function P = evaluate(this, L, T)
      P = this.output.evaluate(L, T);
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
