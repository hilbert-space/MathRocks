classdef LogPolynomial < Regression.Polynomial
  methods
    function this = LogPolynomial(varargin)
      this = this@Regression.Polynomial(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, targetData, parameterData, options)
      [ output, arguments, body ] = construct@Regression.Polynomial( ...
        this, log(targetData), parameterData, options);

      string = sprintf('@(%s)exp(%s)', arguments, body);
      output.evaluate = str2func(string);
    end
  end
end
