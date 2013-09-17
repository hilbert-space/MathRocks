classdef LogPolynomial < Regression.Polynomial
  methods
    function this = LogPolynomial(varargin)
      this = this@Regression.Polynomial(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, grid, options)
      [ output, arguments, body ] = this.regress( ...
        log(grid.targetData), grid.parameterData, options);

      string = sprintf('@(%s)exp(%s)', arguments, body);
      output.evaluate = str2func(string);
    end
  end
end
