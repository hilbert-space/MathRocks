classdef Legendre < PolynomialChaos.Base
  methods
    function this = Legendre(varargin)
      this = this@PolynomialChaos.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function distribution = configure(this, options)
      distribution = ProbabilityDistribution.Uniform('a', -1, 'b', 1);
    end

    function basis = constructBasis(this, x, order)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Legendre_polynomials#Recursive_definition
      %

      assert(order >= 0);

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
      % order of polynomial chaos expansions. So, +1 here.
      %
      quadrature = Quadrature.GaussLegendre( ...
        'dimensionCount', this.inputCount, ...
        'order', polynomialOrder + 1, varargin{:});
    end

    function norm = computeNormalizationConstant(~, i, indexes)
      %
      % Reference:
      %
      % http://en.wikipedia.org/wiki/Legendre_polynomials#Orthogonality
      %

      n = double(indexes(i, :)) - 1;

      %
      % NOTE: Here we also divide by 2 to preserve the weight of
      % the uniform distribution on the interval [-1, 1].
      %
      norm = prod(2 ./ (2 * n + 1) / 2);
    end
  end
end
