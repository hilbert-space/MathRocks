classdef Local < StochasticCollocation.Base
  properties (SetAccess = 'private')
    basis
  end

  methods
    function this = Local(varargin)
      this = this@StochasticCollocation.Base(varargin{:});
      this.basis = Basis.Local.NewtonCotesHat;
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
