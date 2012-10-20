classdef ProbabilistHermite < PolynomialChaos.Base
  methods
    function this = ProbabilistHermite(varargin)
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
        options, 'rules', 'ProbabilistGaussHermite');

      %
      % In each dimension, the rule has the weight function equal to e^(-x^2 / 2);
      % therefore, need to account for the Gaussian constant assuming the variance
      % equal to one.
      %
      nodes   = quadrature.nodes;
      weights = quadrature.weights / (2 * pi)^(options.dimension / 2);
    end

    function norm = computeNormalizationConstant(this, i, index)
      %
      % sqrt(2 * pi) is preserved as discussed above.
      %
      index = index(i, :) - 1;
      norm = prod(factorial(index));
    end
  end
end
