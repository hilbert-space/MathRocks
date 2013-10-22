classdef DimensionAdaptive < SparseGrid.Base
  properties (SetAccess = 'private')
    basis
    adaptivityDegree
  end

  methods
    function this = DimensionAdaptive(varargin)
      options = Options(varargin{:});
      this = this@SparseGrid.Base(options);
      this.basis = Basis.Hat.DimensionWise('maximalLevel', this.maximalLevel);
      this.adaptivityDegree = options.get('adaptivityDegree', 0.9);
    end

    function stats = analyze(this, output)
      stats.expectation = this.basis.computeExpectation( ...
        output.indexes, output.surpluses, output.offsets, output.counts);
      stats.variance = this.basis.computeVariance( ...
        output.indexes, output.surpluses, output.offsets, output.counts);
    end

    function values = evaluate(this, output, nodes)
      values = this.basis.evaluate(nodes, ...
        output.indexes, output.surpluses);
    end
  end
end
