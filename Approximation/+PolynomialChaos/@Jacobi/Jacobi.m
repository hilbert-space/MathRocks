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

    function data = sample(this, sampleCount, varargin)
      %
      % NOTE: We have +1 here as MATLAB's interpretation of the Beta distribution
      % is different from the one used for Jocobi chaos.
      %
      data = betarnd(this.alpha + 1, this.beta + 1, sampleCount, this.inputCount);
      data = data * (this.b - this.a) + this.a;
      data = this.evaluate(data, varargin{:});
    end
  end

  methods (Access = 'protected')
    function configure(this, options)
      this.alpha = options.alpha;
      this.beta = options.beta;
      this.a = options.a;
      this.b = options.b;
    end

    function basis = constructUnivariateBasis(this, x, order)
      assert(order >= 0);

      basis(1) = sympoly(1);
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

    function [ nodes, weights ] = constructQuadrature(this, options)
      quadrature = Quadrature( ...
        'dimensionCount', this.inputCount, ...
        'ruleName', 'GaussJacobi', ...
        'ruleArguments', { this.alpha, this.beta, this.a, this.b }, ...
        options);

      nodes = quadrature.nodes;
      weights = quadrature.weights;
    end

    function norm = computeNormalizationConstant(this, i, index)
      n = index(i, :) - 1;

      alpha = this.alpha;
      beta_ = this.beta;
      a = this.a;
      b = this.b;

      c = 2^(alpha + beta_ + 1) ./ (2 * n + alpha + beta_ + 1);
      d = gamma(n + alpha + 1) .* gamma(n + beta_ + 1) ./ ...
        (gamma(n + 1) .* gamma(n + alpha + beta_ + 1));

      %
      % NOTE: The product of the above two cancels out all the weight;
      % however, we want to preserve the beta weight and, therefore,
      % divide by the following constant.
      %
      e = (b - a)^(alpha + beta_ + 1) * beta(alpha + 1, beta_ + 1);

      norm = prod(c .* d ./ e);
    end
  end
end
