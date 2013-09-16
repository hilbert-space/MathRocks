classdef Expression < Fitting
  methods
    function this = Expression(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, targetData, parameterData, options)
      expression = options.expression;

      Y = targetData(:);

      pointCount = length(Y);
      dimensionCount = length(parameterData);

      X = zeros(pointCount, dimensionCount);
      for i = 1:dimensionCount
        X(:, i) = parameterData{i}(:);
      end

      output.evaluate = Utils.constructCustomFit(X, Y, ...
        expression.formula, expression.parameters, expression.coefficients);
    end

    function target = evaluate(this, output, varargin)
      target = output.evaluate(varargin{:});
    end
  end
end
