classdef GaussLegendre < Quadrature.Base
  methods
    function this = GaussLegendre(varargin)
      this = this@Quadrature.Base( ...
        'distribution', ProbabilityDistribution.Uniform, ...
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

      a = this.distribution.a;
      b = this.distribution.b;

      [ nodes, weights ] = legendre_compute(order);

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
      nodes = ((nodes + 1) / 2) * (b - a) + a;
      weights = weights / 2;
    end
  end
end
