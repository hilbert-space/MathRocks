classdef Linear < Fitting
  methods
    function this = Linear(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    function output = construct(this, targetData, parameterData, options)
      output.F = griddedInterpolant( ...
        parameterData{:}, targetData, 'linear', 'none');
    end

    function target = evaluate(this, output, varargin)
      assert(length(varargin) == this.parameterCount);
      dimensions = size(varargin{1});
      for i = 1:this.parameterCount
        varargin{i} = varargin{i}(:);
      end
      target = reshape(output.F(varargin{:}), dimensions);
    end
  end
end
