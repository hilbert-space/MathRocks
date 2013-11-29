classdef Polynomial < Fitting.Base
  methods
    function this = Polynomial(varargin)
      this = this@Fitting.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = regress(this, Z, XY, options)

    function evaluator = construct(this, grid, options)
      termPowers = cell(1, grid.parameterCount);
      names = this.parameterNames;
      for i = 1:grid.parameterCount
        termPowers{i} = options.termPowers.(names{i});
      end

      evaluator = this.regress( ...
        grid.targetData, grid.parameterData, termPowers);
    end
  end
end
