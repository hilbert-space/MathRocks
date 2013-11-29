classdef Jacobi < PolynomialChaos.Base
  methods
    function this = Jacobi(varargin)
      this = this@PolynomialChaos.Base('distribution', ...
        ProbabilityDistribution.Beta, varargin{:});
    end
  end

  methods (Access = 'protected')
    function basis = constructBasis(this, x, order)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Jacobi_polynomials#Recursion_relation
      %
      a = this.distribution.a;
      b = this.distribution.b;
      [ alpha, beta ] = Utils.toJacobiExponents( ...
        this.distribution.alpha, this.distribution.beta);

      x = 2 * (x - a) / (b - a) - 1; % standardize

      basis = sym(zeros(1, order + 1));

      basis(1) = sym(1);
      if order == 0, return; end

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
        'distribution', this.distribution, ...
        'dimensionCount', this.inputCount, ...
        'level', (polynomialOrder + 1) - 1, ...
        'growth', 'slow-linear', ...
        varargin{:});
    end

    function norm = computeNormalizationConstant(this, index)
      %
      % Denote the norm of the standard Jacobi polynomials, defined on
      % the interval [-1, 1], with the parameters alpha' and beta' by
      %
      %  J(alpha', beta', n).
      %
      % After the standardization
      %
      %  x = 2 * (x - a) / (b - a) - 1,
      %
      % the norm becomes
      %
      %  (b - a)^(alpha' + beta' + 1)
      %  ---------------------------- * J(alpha', beta', n).
      %      2^(alpha' + beta' + 1)
      %
      % The normalization constant of the four-parameter beta
      % distribution with the parameters alpha, beta, a, and b is
      %
      %                        1
      %  ----------------------------------------------.
      %  (b - a)^(alpha + beta - 1) * Beta(alpha, beta)
      %
      % This weight should be preserved; thus, the norm of the
      % properly weighted Jacobi polynomials with the parameters
      % alpha' = beta - 1, beta' = alpha - 1, a, and b is
      %
      %                     1
      %  ---------------------------------------- * J(beta - 1, alpha - 1, n).
      %  2^(alpha + beta - 1) * Beta(alpha, beta)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Jacobi_polynomials#Orthogonality
      %
      n = double(index);

      alpha = this.distribution.alpha;
      beta_ = this.distribution.beta; % do not overwrite the beta function

      %
      % Convert beta exponents to Jacobi exponents
      %
      [ alpha, beta_ ] = Utils.toJacobiExponents(alpha, beta_);

      c = 2^(alpha + beta_ + 1) ./ (2 * n + alpha + beta_ + 1);
      d = gamma(n + alpha + 1) .* gamma(n + beta_ + 1) ./ ...
        (gamma(n + alpha + beta_ + 1) .* gamma(n + 1));

      %
      % Convert Jacobi exponents back to beta exponents
      %
      [ alpha, beta_ ] = Utils.toBetaExponents(alpha, beta_);

      e = 2^(alpha + beta_ - 1) * beta(alpha, beta_);

      norm = prod(c .* d ./ e);
    end
  end
end
