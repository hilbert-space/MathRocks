classdef LogPolynomial < Regression.Polynomial
  methods
    function this = LogPolynomial(varargin)
      this = this@Regression.Polynomial(varargin{:});
    end
  end

  methods (Access = 'protected')
    output = construct(this, target, parameters, options)
  end
end
