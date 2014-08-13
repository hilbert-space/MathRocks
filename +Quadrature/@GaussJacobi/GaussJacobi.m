classdef GaussJacobi < Quadrature.Base
  methods
    function this = GaussJacobi(varargin)
      this = this@Quadrature.Base('distribution', ...
        ProbabilityDistribution.Beta, varargin{:});
    end
  end

  methods (Access = 'protected')
    function [nodes, weights] = rule(this, order)
      [alpha, beta] = Utils.toJacobiExponents( ...
        this.distribution.alpha, this.distribution.beta);

      [nodes, weights] = jacobi_compute(order, alpha, beta);
      nodes = nodes(:); % returned as a row vector

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
      a = this.distribution.a;
      b = this.distribution.b;

      nodes = ((nodes + 1) / 2) * (b - a) + a;
      weights = weights / sum(weights);
      % ... or weights / 2^(alpha + beta_ - 1) / beta(alpha, beta_)) in 1D.
    end
  end
end
