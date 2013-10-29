classdef Global < StochasticCollocation.Hierarchical.Base
  methods
    function this = Global(varargin)
      this = this@StochasticCollocation.Hierarchical.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function interpolant = configure(~, options)
      interpolant = Interpolation.Hierarchical.Global(options);
    end
  end
end
