classdef PolynomialRegression < LeakagePower.Base
  methods
    function this = PolynomialRegression(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = construct(this, Ldata, Tdata, Idata, options)

    function I = evaluate(this, output, L, T)
      I = output.evaluate(L, T);
    end
  end
end
