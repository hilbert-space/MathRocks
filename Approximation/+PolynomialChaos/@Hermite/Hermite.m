classdef Hermite < PolynomialChaos.Base
  methods
    function this = Hermite(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function basis = constructUnivariateBasis(this, x, order)
      assert(order >= 0);

      basis(1) = sympoly(1);
      if order == 0, return; end

      basis(2) = x;
      if order == 1, return; end

      for i = 3:(order + 1)
        basis(i) = x * basis(i - 1) - (i - 2) * basis(i - 2);
      end
    end

    function [ nodes, weights ] = constructQuadrature(this, options)
      quadrature = Quadrature.(options.name)( ...
        'rules', 'GaussHermite', options);

      nodes = quadrature.nodes;
      weights = quadrature.weights;
    end

    function norm = computeNormalizationConstant(this, i, index)
      index = index(i, :) - 1;
      norm = prod(factorial(index));
    end
  end
end
