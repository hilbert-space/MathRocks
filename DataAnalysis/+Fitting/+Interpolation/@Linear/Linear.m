classdef Linear < Fitting.Base
  methods
    function this = Linear(varargin)
      this = this@Fitting.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(~, grid, ~)
      output.F = griddedInterpolant( ...
        grid.parameterData{:}, grid.targetData, 'linear', 'none');
    end

    function target = evaluate(~, output, varargin)
      target = output.F(varargin{:});
    end
  end
end
