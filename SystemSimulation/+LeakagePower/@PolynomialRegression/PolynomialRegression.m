classdef PolynomialRegression < LeakagePower.Base
  methods
    function this = PolynomialRegression(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = construct(this, V, T, I, options)

    function I = evaluate(this, output, V, T)
      I = output.evaluate(V, T);
    end
  end
end
