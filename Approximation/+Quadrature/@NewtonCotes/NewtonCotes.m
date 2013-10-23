classdef NewtonCotes < Quadrature.Base
  methods
    function this = NewtonCotes(varargin)
      this = this@Quadrature.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(~, order, ~)
      if order == 1
        nodes = 0.5;
      else
        count = 2^(order - 1) + 1;
        nodes = ((1:count)' - 1) / (count - 1);
      end
      weights = ones(size(nodes, 1), 1); % unknown
    end
  end
end
