classdef Sparse < Quadrature.Base
  methods
    function this = Sparse(varargin)
      this = this@Quadrature.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    [ nodes, weights ] = construct(this, options)
  end
end
