classdef Global < Interpolation.Hierarchical.Base
  properties (SetAccess = 'private')
    adaptivityDegree
  end

  methods
    function this = Global(varargin)
      this = this@Interpolation.Hierarchical.Base(varargin{:});
    end

    function result = integrate(this, output)
      result = this.basis.integrate( ...
        output.indexes, output.surpluses, output.offsets, output.counts);
    end

    function values = evaluate(this, output, nodes)
      values = this.basis.evaluate(nodes, ...
        output.indexes, output.surpluses);
    end
  end

  methods (Access = 'protected')
    function basis = configure(this, options)
      basis = Basis.Hierarchical.Global.NewtonCotesHat(options);
      this.adaptivityDegree = options.get('adaptivityDegree', 0.9);
    end
  end
end
