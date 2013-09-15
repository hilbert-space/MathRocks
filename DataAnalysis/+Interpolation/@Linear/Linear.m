classdef Linear < Fitting
  methods
    function this = Linear(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, target, parameters, options)
      output.F = griddedInterpolant(parameters{:}, target, 'linear', 'none');
    end

    function target = evaluate(this, output, parameters)
      dimensions = size(parameters{1});
      for i = 1:length(parameters), parameters{i} = parameters{i}(:); end
      target = reshape(output.F(parameters{:}), dimensions);
    end
  end
end
