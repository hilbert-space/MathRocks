classdef Expression < Fitting
  methods
    function this = Expression(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, target, parameters, options)
      expression = options.expression;

      Y = target(:);

      pointCount = length(Y);
      dimensionCount = length(parameters);

      X = zeros(pointCount, dimensionCount);
      for i = 1:dimensionCount
        X(:, i) = parameters{i}(:);
      end

      output.evaluate = Utils.constructCustomFit(X, Y, ...
        expression.formula, expression.parameters, expression.coefficients);
    end

    function target = evaluate(this, output, parameters)
      target = output.evaluate(parameters{:});
    end
  end
end
