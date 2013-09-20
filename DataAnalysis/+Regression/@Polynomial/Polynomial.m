classdef Polynomial < Fitting
  methods
    function this = Polynomial(varargin)
      this = this@Fitting(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ output, arguments, body ] = regress(this, Z, XY, options)

    function output = construct(this, grid, options)
      output = this.regress(grid.targetData, grid.parameterData, options);
    end

    function target = evaluate(~, output, varargin)
      target = output.evaluate(varargin{:});
    end
  end
end
