classdef GaussLegendre < Quadrature.Base
  methods
    function this = GaussLegendre(varargin)
      this = this@Quadrature.Base('distribution', ...
        ProbabilityDistribution.Uniform, varargin{:});
    end
  end

  methods (Access = 'protected')
    function [nodes, weights] = rule(this, order)
      [nodes, weights] = legendre_compute(order);

      %
      % We would like to compute integrals with respect to the density
      % of the uniform distribution on the interval [a, b]:
      %
      %         b
      %         /          1
      %  g(x) = | h(x) * ----- * dx.
      %         /        b - a
      %         a
      %
      % However, the computed nodes and weights are for the integrals
      % of the following form:
      %
      %         1
      %         /
      %  g(y) = | h(y) * dy.
      %         /
      %        -1
      %
      % Therefore, we use the following change of variables:
      %
      %          x - a
      %  y = 2 * ----- - 1,
      %          b - a
      %
      %      y + 1
      %  x = ----- * (b - a) + a, and
      %        2
      %
      %       b - a
      %  dx = ----- * dy.
      %         2
      %
      a = this.distribution.a;
      b = this.distribution.b;

      nodes = ((nodes + 1) / 2) * (b - a) + a;
      weights = weights / sum(weights);
      % ... or weights / 2 in 1D.
    end
  end
end
