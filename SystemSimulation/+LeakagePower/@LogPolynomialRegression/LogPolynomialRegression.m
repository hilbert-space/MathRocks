classdef LogPolynomialRegression < LeakagePower.PolynomialRegression
  methods
    function this = LogPolynomialRegression(varargin)
      this = this@LeakagePower.PolynomialRegression(varargin{:});
    end
  end

  methods (Access = 'protected')
    output = construct(this, V, T, I, options)
  end
end
