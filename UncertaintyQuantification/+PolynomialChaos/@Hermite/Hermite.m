classdef Hermite < PolynomialChaos.Base
  methods
    function this = Hermite(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function distribution = configure(~, ~)
      distribution = ProbabilityDistribution.Gaussian;
    end

    function basis = constructBasis(~, x, order)
      assert(order >= 0);

      basis = sym(zeros(1, order + 1));

      basis(1) = sym(1);
      if order == 0, return; end

      basis(2) = x;
      if order == 1, return; end

      for i = 3:(order + 1)
        basis(i) = x * basis(i - 1) - (i - 2) * basis(i - 2);
      end
    end

    function quadrature = constructQuadrature(this, polynomialOrder, varargin)
      %
      % NOTE: An n-order Gaussian quadrature rule integrates
      % polynomials of order (2 * n - 1) exactly. We want to have
      % exactness for polynomials of order (2 * n) where n is the
      % order of polynomial chaos expansions. Therefore, the order
      % of the quadrature should be (polynomialOrder + 1). Using
      % the slow-linear growth rule, the level is then (order - 1).
      %
      quadrature = Quadrature.GaussHermite( ...
        'dimensionCount', this.inputCount, ...
        'level', (polynomialOrder + 1) - 1, ...
        'growth', 'slow-linear', ...
        varargin{:});
    end

    function norm = computeNormalizationConstant(~, i, indexes)
      n = double(indexes(i, :)) - 1;

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
