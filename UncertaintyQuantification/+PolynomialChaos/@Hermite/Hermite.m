classdef Hermite < PolynomialChaos.Base
  methods
    function this = Hermite(varargin)
      this = this@PolynomialChaos.Base('distribution', ...
        ProbabilityDistribution.Gaussian, varargin{:});
    end
  end

  methods (Access = 'protected')
    function basis = constructBasis(this, x, order)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Hermite_polynomials#Recursion_relation
      %
      mu = this.distribution.mu;
      sigma = this.distribution.sigma;

      x = (x - mu) / sigma; % standardize

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
        'distribution', this.distribution, ...
        'dimensionCount', this.inputCount, ...
        'level', (polynomialOrder + 1) - 1, ...
        'growth', 'slow-linear', ...
        varargin{:});
    end

    function norm = computeNormalizationConstant(~, index)
      %
      % The norm of the standard Hermite polynomials is
      %
      % sqrt(2 * pi) * factorial(n).
      %
      % After the standardization
      %
      % x = (x - mu) / sigma,
      %
      % the norm becomes
      %
      % sqrt(2 * pi) * sigma * factorial(n).
      %
      % The part before the factorial belongs to the corresponding
      % Gaussian density and, thus, should be preserved. Therefore,
      % the norm of the properly weighted Hermite polynomials is
      %
      % factorial(n).
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Hermite_polynomials#Orthogonality
      %
      n = double(index);
      norm = prod(factorial(n));
    end
  end
end
