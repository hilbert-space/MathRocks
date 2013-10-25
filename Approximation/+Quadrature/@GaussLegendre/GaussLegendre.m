classdef GaussLegendre < Quadrature.Base
  methods
    function this = GaussLegendre(varargin)
      this = this@Quadrature.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(~, order, ~)
      [ nodes, weights ] = legendre_compute(order);
      %
      % The computed nodes and weights can be used to evaluate integrals
      % on the interval [-1, 1] with the weight function equal to one.
      % However, we need the weight of the uniform ditribution on [-1, 1],
      % which is one over two. So,
      %
      weights = weights / 2;
    end
  end
end
