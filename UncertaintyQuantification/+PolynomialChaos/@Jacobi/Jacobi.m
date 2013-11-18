classdef Jacobi < PolynomialChaos.Base
  properties (SetAccess = 'private')
    alpha
    beta
    a
    b
  end

  methods
    function this = Jacobi(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function distribution = configure(this, options)
      this.alpha = options.get('alpha', 2);
      this.beta = options.get('beta', 2);
      this.a = options.get('a', -1);
      this.b = options.get('b', 1);

      %
      % NOTE: We have +1 here as MATLAB's interpretation of
      % the Beta distribution is different from the one used
      % for the Jacobi chaos.
      %
      distribution = ProbabilityDistribution.Beta( ...
        'alpha', this.alpha + 1, 'beta', this.beta + 1, ...
        'a', this.a, 'b', this.b);
    end

    function basis = constructBasis(this, x, order)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Jacobi_polynomials#Recurrence_relation
      %

      assert(order >= 0);

      a = this.a;
      b = this.b;

      x = 2 * (x - a) / (b - a) - 1;

      basis = sym(zeros(1, order + 1));

      basis(1) = sym(1);
      if order == 0, return; end

      alpha = this.alpha;
      beta = this.beta;

      basis(2) = (1 / 2) * (2 * (alpha + 1) + (alpha + beta + 2) * (x - 1));
      if order == 1, return; end

      for i = 3:(order + 1)
        n = i - 1;
        c1 = (2 * n + alpha + beta - 1) * ((2 * n + alpha + beta) * (2 * n + alpha + beta - 2) * x + alpha^2 - beta^2);
        c2 = 2 * (n + alpha - 1) * (n + beta - 1) * (2 * n + alpha + beta);
        c3 = 2 * n * (n + alpha + beta) * (2 * n + alpha + beta - 2);
        basis(i) = (c1 * basis(i - 1) - c2 * basis(i - 2)) / c3;
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
      quadrature = Quadrature.GaussJacobi( ...
        'dimensionCount', this.inputCount, ...
        'level', (polynomialOrder + 1) - 1, ...
        'growth', 'slow-linear', ...
        'alpha', this.alpha, 'beta', this.beta, ...
        'a', this.a, 'b', this.b, varargin{:});
    end

    function norm = computeNormalizationConstant(this, i, indexes)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Jacobi_polynomials#Orthogonality
      %

      n = double(indexes(i, :)) - 1;

      alpha = this.alpha;
      beta_ = this.beta;
      a = this.a;
      b = this.b;

      c = 2^(alpha + beta_ + 1) ./ (2 * n + alpha + beta_ + 1);
      d = gamma(n + alpha + 1) .* gamma(n + beta_ + 1) ./ ...
        (gamma(n + alpha + beta_ + 1) .* gamma(n + 1));

      %
      % NOTE: The product of the above two cancels out the weight;
      % however, we want to preserve the beta weight and, therefore,
      % divide by the following constant. Also, +1 is due to the fact
      % pointed out earlier.
      %
      e = (b - a)^(alpha + 1 + beta_ + 1 - 1) * beta(alpha + 1, beta_ + 1);

      norm = prod(c .* d ./ e);
    end
  end
end
