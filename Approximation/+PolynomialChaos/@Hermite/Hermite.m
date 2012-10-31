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
      quadrature = Quadrature( ...
        'dimension', this.inputCount, ...
        'ruleName', 'GaussHermite', ...
        options);

      nodes = quadrature.nodes;
      weights = quadrature.weights;
    end

    function norm = computeNormalizationConstant(this, i, index)
      n = index(i, :) - 1;

      %
      % NOTE: The original probabilists' Hermite polynomials have
      % normalization constants equal to sqrt(2 * pi) * factorial(n).
      % However, all the quadrature rules are assumed to produce purely
      % probabilists' nodes and weights; in other words, sqrt(2 * pi)
      % is preserved as it is a part of the Gaussian measure.
      %
      norm = prod(factorial(n));
    end
  end
end
