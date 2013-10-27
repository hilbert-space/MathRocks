classdef Local < SparseGridInterpolation.Base
  properties (SetAccess = 'private')
    basis
  end

  methods
    function this = Local(varargin)
      this = this@SparseGridInterpolation.Base(varargin{:});
      this.basis = HierarchicalBasis.NewtonCotesHat.Local;
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
