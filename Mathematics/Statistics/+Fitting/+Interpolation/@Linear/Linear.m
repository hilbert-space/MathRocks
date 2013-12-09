classdef Linear < Fitting.Base
  methods
    function this = Linear(varargin)
      this = this@Fitting.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function evaluator = construct(~, grid, ~)
      evaluator = griddedInterpolant(grid.parameterData{:}, ...
        grid.targetData, 'linear', 'nearest');
    end
  end
end
