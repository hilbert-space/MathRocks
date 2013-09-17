classdef Expression < Fitting
  methods
    function this = Expression(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, grid, options)
      Fs = options.expression.formula;
      Xs = options.expression.parameters;
      Cs = options.expression.coefficients;

      assert(length(Xs) == grid.parameterCount);

      Y = grid.targetData(:);
      pointCount = length(Y);

      X = zeros(pointCount, grid.parameterCount);
      for i = 1:grid.parameterCount
        parameter = char(Xs(i));

        k = NaN;
        for j = 1:grid.parameterCount
          if strcmp(grid.parameterNames{i}, parameter)
            k = j;
            break;
          end
        end
        assert(~isnan(k));

        X(:, i) = grid.parameterData{k}(:);
      end

      output.evaluate = Utils.constructCustomFit(Y, X, Fs, Xs, Cs);
    end

    function target = evaluate(this, output, varargin)
      target = output.evaluate(varargin{:});
    end
  end
end
