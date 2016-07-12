classdef Custom < Fitting.Base
  properties (SetAccess = 'protected')
    expression
  end

  methods
    function this = Custom(varargin)
      this = this@Fitting.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function evaluator = construct(this, grid, options)
      expression = options.expression;

      Fs = expression.formula;
      Xs = expression.parameters;
      Cs = expression.coefficients;

      assert(length(Xs) == grid.parameterCount);

      Y = grid.targetData(:);
      pointCount = length(Y);

      X = zeros(pointCount, grid.parameterCount);
      for i = 1:grid.parameterCount
        parameter = char(Xs(i));

        k = NaN;
        for j = 1:grid.parameterCount
          if strcmp(grid.parameterNames{j}, parameter)
            k = j;
            break;
          end
        end
        assert(~isnan(k));

        X(:, i) = grid.parameterData{k}(:);
      end

      Fs = Utils.regress(Y, X, Fs, Xs, Cs);

      expression = struct;
      expression.formula = Fs;
      expression.parameters = Xs;

      this.expression = expression;

      Xs = num2cell(Xs);
      evaluator = Utils.toFunction(Fs, Xs{:});
    end
  end
end
