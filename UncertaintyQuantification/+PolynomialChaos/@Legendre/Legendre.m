classdef Legendre < PolynomialChaos.Base
  properties (SetAccess = 'private')
    a
    b
  end

  methods
    function this = Legendre(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function distribution = configure(this, options)
      this.a = options.get('a', -1);
      this.b = options.get('b', 1);

      distribution = ProbabilityDistribution.Uniform( ...
        'a', this.a, 'b', this.b);
    end

    function basis = constructBasis(this, x, order)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Legendre_polynomials#Recursive_definition
      %

      assert(order >= 0);

      a = this.a;
      b = this.b;

      x = 2 * (x - a) / (b - a) - 1;

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
        'dimensionCount', this.inputCount, ...
        'level', (polynomialOrder + 1) - 1, ...
        'growth', 'slow-linear', ...
        'a', this.a, 'b', this.b, varargin{:});
    end

    function norm = computeNormalizationConstant(this, i, indexes)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Legendre_polynomials#Orthogonality
      %

      n = double(indexes(i, :)) - 1;

      %
      % NOTE: Here we also divide by (b - a) to preserve the weight of
      % the uniform distribution on the interval [a, b].
      %
      norm = prod(2 ./ (2 * n + 1) / (this.b - this.a));
    end
  end
end
