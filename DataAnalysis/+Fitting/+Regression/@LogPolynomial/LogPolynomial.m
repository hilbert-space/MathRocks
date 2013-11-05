classdef LogPolynomial < Fitting.Regression.Polynomial
  methods
    function this = LogPolynomial(varargin)
      this = this@Fitting.Regression.Polynomial(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, grid, options)
      termPowers = cell(1, grid.parameterCount);
      names = this.parameterNames;
      for i = 1:grid.parameterCount
        termPowers{i} = options.termPowers.(names{i});
      end

      [ output, arguments, body ] = this.regress( ...
        log(grid.targetData), grid.parameterData, termPowers);

      string = sprintf('@(%s)exp(%s)', arguments, body);
      output.evaluate = str2func(string);
    end
  end
end
