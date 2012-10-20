classdef PhysicistHermite < PolynomialChaos.Base
  methods
    function this = PhysicistHermite(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function basis = constructUnivariateBasis(this, x, order)
      assert(order >= 0);

      basis(1) = sympoly(1);
      if order == 0, return; end

      basis(2) = 2 * x;
      if order == 1, return; end

      for i = 3:(order + 1)
        basis(i) = 2 * x * basis(i - 1) - 2 * (i - 2) * basis(i - 2);
      end
    end

    function [ nodes, weights ] = constructQuadrature(this, options)
      quadrature = Quadrature.(options.name)( ...
        options, 'rules', 'PhysicistGaussHermite');

      %
      % In each dimension, the rule has the weight function equal to e^(-x^2);
      % therefore, need to account for the Gaussian constant assuming the variance
      % equal to one half.
      %
      nodes   = quadrature.nodes;
      weights = quadrature.weights / pi^(options.dimension / 2);
    end

    function norm = computeNormalizationConstant(this, i, index)
      %
      % sqrt(pi) is preserved as discussed above.
      %
      index = index(i, :) - 1;
      norm = prod(2.^index .* factorial(index));
    end
  end
end
