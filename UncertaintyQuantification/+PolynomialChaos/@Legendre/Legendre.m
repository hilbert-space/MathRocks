classdef Legendre < PolynomialChaos.Base
  methods
    function this = Legendre(varargin)
      this = this@PolynomialChaos.Base('distribution', ...
        ProbabilityDistribution.Uniform, varargin{:});
    end
  end

  methods (Access = 'protected')
    function basis = constructBasis(this, x, order)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Legendre_polynomials#Recursion_relation
      %
      a = this.distribution.a;
      b = this.distribution.b;

      x = 2 * (x - a) / (b - a) - 1; % standardize

      basis = sym(zeros(1, order + 1));

      basis(1) = sym(1);
      if order == 0, return; end

      basis(2) = x;
      if order == 1, return; end

      for n = 1:(order - 1)
        basis(n + 1 + 1) = ((2 * n + 1) * x * basis(n + 1) - ...
          n * basis(n - 1 + 1)) / (n + 1);
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
      quadrature = Quadrature.GaussLegendre( ...
        'distribution', this.distribution, ...
        'dimensionCount', this.inputCount, ...
        'level', (polynomialOrder + 1) - 1, ...
        'growth', 'slow-linear', ...
        varargin{:});
    end

    function norm = computeNormalizationConstant(~, index)
      %
      % The norm of the standard Legendre polynomials, defined on
      % the interval [-1, 1], is
      %
      %      2
      %  ---------.
      %  2 * n + 1
      %
      % After the standardization
      %
      %  x = 2 * (x - a) / (b - a) - 1,
      %
      % the norm becomes
      %
      %  b - a       2         b - a
      %  ----- * --------- = ---------.
      %    2     2 * n + 1   2 * n + 1
      %
      % The normalization constant of the uniform distribution on
      % the interval [a, b] is
      %
      %    1
      %  -----.
      %  b - a
      %
      % This weight should be preserved; thus, the norm of the
      % properly weighted Legendre polynomials is
      %
      %      1
      %  ---------.
      %  2 * n + 1
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Legendre_polynomials#Orthogonality
      %
      n = double(index);
      norm = prod(1 ./ (2 * n + 1));
    end
  end
end
