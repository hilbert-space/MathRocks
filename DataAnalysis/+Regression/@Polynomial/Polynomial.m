classdef Polynomial < Fitting
  methods
    function this = Polynomial(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = regress(this, Z, XY, options)

    function output = construct(this, grid, options)
      termPowers = cell(1, grid.parameterCount);
      names = this.parameterNames;
      for i = 1:grid.parameterCount
        termPowers{i} = options.termPowers.(names{i});
      end

      output = this.regress( ...
        grid.targetData, grid.parameterData, termPowers);
    end

    function target = evaluate(~, output, varargin)
      target = output.evaluate(varargin{:});
    end
  end
end
