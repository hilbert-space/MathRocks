classdef SpaceAdaptive < SparseGrid.Base
  properties (SetAccess = 'private')
    basis
  end

  methods
    function this = SpaceAdaptive(varargin)
      this = this@SparseGrid.Base(varargin{:});
      this.basis = Basis.Hat.SpaceWise;
    end

    function stats = analyze(this, output)
      stats.expectation = this.basis.computeExpectation( ...
        output.levels, output.surpluses);
      stats.variance = this.basis.computeVariance( ...
        output.levels, output.orders, output.surpluses);
    end

    function values = evaluate(this, output, nodes)
      values = this.basis.evaluate(nodes, ...
        output.levels, output.orders, output.surpluses);
    end
  end
end
