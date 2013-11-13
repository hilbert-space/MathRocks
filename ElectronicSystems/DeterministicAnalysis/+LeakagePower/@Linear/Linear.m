classdef Linear < LeakagePower.Base
  methods
    function this = Linear(varargin)
      this = this@LeakagePower.Base(varargin{:});
    end

    function [ alpha, beta ] = linearize(this, varargin)
      options = Options(varargin{:});

      %
      % Find the fitted alpha and beta coefficients
      %
      expression = this.surrogate.expression;

      beta = subs(expression.formula, 'T', 0);
      alpha = double(subs(expression.formula - beta, 'T', 1));
      parameters = num2cell(expression.parameters);

      %
      % Update the evaluation function
      %
      this.evaluate = Utils.toFunction(this.powerScale * ...
        (options.ambientTemperature * alpha + beta), parameters{:});
    end
  end

  methods (Access = 'protected')
    surrogate = construct(this, options)
  end
end
