classdef PolynomialRegression < LeakagePower.Base
  methods
    function this = PolynomialRegression(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ evaluate, stats ] = construct(this, Ldata, Tdata, Idata, options)
  end
end
