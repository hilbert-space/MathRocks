classdef ChebyshevGaussLobatto < Quadrature.Base
  methods
    function this = ChebyshevGaussLobatto(varargin)
      this = this@Quadrature.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(~, order, ~)
      if order == 1
        nodes = 0.5;
      else
        count = 2^(order - 1) + 1;
        nodes = (-cos(pi * ((1:count)' - 1) / (count - 1)) + 1) / 2;
      end
      weights = ones(size(nodes, 1), 1); % unknown
    end
  end
end
