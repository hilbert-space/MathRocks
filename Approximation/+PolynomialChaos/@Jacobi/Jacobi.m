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
      this.alpha = options.alpha;
      this.beta = options.beta;
      this.a = options.a;
      this.b = options.b;

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

      basis = sym(zeros(1, order + 1));

      basis(1) = sym(1);
      if order == 0, return; end

      alpha = this.alpha;
      beta = this.beta;

      basis(2) = (1 / 2) * (2 * (alpha + 1) + (alpha + beta + 2) * (x - 1));
      if order == 1, return; end

      for i = 3:(order + 1)
        n = i - 1;
        a = (2 * n + alpha + beta - 1) * ((2 * n + alpha + beta) * (2 * n + alpha + beta - 2) * x + alpha^2 - beta^2);
        b = 2 * (n + alpha - 1) * (n + beta - 1) * (2 * n + alpha + beta);
        c = 2 * n * (n + alpha + beta) * (2 * n + alpha + beta - 2);
        basis(i) = (a * basis(i - 1) - b * basis(i - 2)) / c;
      end
    end

    function quadrature = constructQuadrature(this, polynomialOrder, varargin)
      %
      % NOTE: An n-order Gaussian quadrature rule integrates
      % polynomials of order (2 * n - 1) exactly. We want to have
      % exactness for polynomials of order (2 * n) where n is the
      % order of polynomial chaos expansions. So, +1 here.
      %
      quadrature = Quadrature.GaussJacobi( ...
        'dimensionCount', this.inputCount, ...
        'order', polynomialOrder + 1, ...
        'alpha', this.alpha, 'beta', this.beta, ...
        'a', this.a, 'b', this.b, varargin{:});
    end

    function norm = computeNormalizationConstant(this, i, indexes)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Jacobi_polynomials#Basic_properties
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
