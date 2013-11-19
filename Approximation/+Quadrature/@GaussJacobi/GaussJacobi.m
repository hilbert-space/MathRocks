classdef GaussJacobi < Quadrature.Base
  methods
    function this = GaussJacobi(varargin)
      this = this@Quadrature.Base( ...
        'distribution', ProbabilityDistribution.Beta, ...
        'growth', 'slow-linear', varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(this, level)
      %
      % First, we determine the growth rule.
      %
      % Reference:
      %
      % http://people.sc.fsu.edu/~jburkardt/cpp_src/sgmg/sgmg.html
      %
      if isa(this.growth, 'function_handle')
        order = feval(this.growth, level);
      elseif strcmpi(this.growth, 'slow-linear')
        order = level + 1;
      elseif strcmpi(this.growth, 'full-exponential')
        order = 2^(level + 1) - 1;
      else
        assert(false);
      end

      alpha = this.distribution.alpha;
      beta_ = this.distribution.beta; % do not overwrite the beta function
      a = this.distribution.a;
      b = this.distribution.b;

      %
      % Convert beta exponents to Jacobi exponents
      %
      [ alpha, beta_ ] = Utils.toJacobiExponents(alpha, beta_);

      [ nodes, weights ] = jacobi_compute(order, alpha, beta_);
      nodes = nodes(:); % returned as a row vector

      %
      % Convert Jacobi exponents back to beta exponents
      %
      [ alpha, beta_ ] = Utils.toBetaExponents(alpha, beta_);

      %
      % We would like to compute integrals with respect to the density
      % of the four-parameter beta distribution with the parameters
      % alpha, beta, a, and b:
      %
      %         b
      %         /           (x - a)^(alpha - 1) * (b - x)^(beta - 1)
      %  g(x) = | h(x) * ---------------------------------------------- * dx.
      %         /        (b - a)^(alpha + beta - 1) * Beta(alpha, beta)
      %         a
      %
      % However, the computed nodes and weights are for the integrals
      % of the following form:
      %
      %        1
      %        /
      % g(y) = | h(y) * (y - (-1))^(alpha - 1) * (1 - y)^(beta - 1) * dy.
      %        /
      %       -1
      %
      % Therefore, we use the following change of variables:
      %
      %         x - a
      % y = 2 * ----- - 1,
      %         b - a
      %
      %     y + 1
      % x = ----- * (b - a) + a, and
      %       2
      %
      %      b - a
      % dx = ----- * dy.
      %        2
      %
      nodes = ((nodes + 1) / 2) * (b - a) + a;
      weights = weights / (2^(alpha + beta_ - 1) * beta(alpha, beta_));
    end
  end
end
