classdef LogPolynomialRegression < LeakagePower.PolynomialRegression
  methods
    function this = LogPolynomialRegression(varargin)
      this = this@LeakagePower.PolynomialRegression(varargin{:});
    end
  end

  methods (Access = 'protected')
    output = construct(this, Ldata, Tdata, Idata, options)
  end
end
