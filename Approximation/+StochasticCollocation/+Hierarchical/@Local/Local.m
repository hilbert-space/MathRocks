classdef Local < StochasticCollocation.Hierarchical.Base
  methods
    function this = Local(varargin)
      this = this@StochasticCollocation.Hierarchical.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function interpolant = configure(~, options)
      interpolant = Interpolation.Hierarchical.Local(options);
    end
  end
end
