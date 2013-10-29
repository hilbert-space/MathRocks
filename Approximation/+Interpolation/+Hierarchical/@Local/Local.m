classdef Local < Interpolation.Hierarchical.Base
  properties (SetAccess = 'private')
    minimalLevel
  end

  methods
    function this = Local(varargin)
      this = this@Interpolation.Hierarchical.Base(varargin{:});
    end

    function result = integrate(this, output)
      result = this.basis.integrate( ...
        output.levels, output.surpluses);
    end

    function values = evaluate(this, output, nodes)
      values = this.basis.evaluate(nodes, ...
        output.levels, output.orders, output.surpluses);
    end
  end

  methods (Access = 'protected')
    function basis = configure(this, options)
      basis = Basis.Hierarchical.Local.NewtonCotesHat(options);
      this.minimalLevel = options.get('minimalLevel', 2);
    end
  end
end
