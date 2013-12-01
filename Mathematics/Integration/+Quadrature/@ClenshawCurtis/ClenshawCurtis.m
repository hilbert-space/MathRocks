classdef ClenshawCurtis < Quadrature.Base
  methods
    function this = ClenshawCurtis(varargin)
      this = this@Quadrature.Base('distribution', ...
        ProbabilityDistribution.Uniform, varargin{:});
    end
  end

  methods (Access = 'protected')
    function order = computeOrder(this, level)
      %
      % Reference:
      %
      % http://people.sc.fsu.edu/~jburkardt/m_src/sgmga/sgmga.html
      %

      %
      % NOTE: Only one growth rule is supported for now.
      %
      assert(strcmpi(this.growth, 'full-exponential'));

      if level == 0
        order = 1;
      else
        order = 2^level + 1;
      end
    end

    function [ nodes, weights ] = rule(this, order)
      if order == 1 % special case
        nodes = 0;
        weights = 2;
        return;
      end

      %
      % Reference:
      %
      % J. Waldvogel. Fast Construction of the Fejer and Clenshaw-Curtis
      % Quadrature Rules. BIT Numerical Mathematics. March 2006, Volume 46,
      % Issue 1, pp. 195--202.
      %
      n = order;
      m = n - 1;
      c = zeros(1, n);
      c(1:2:n) = 2 ./ [ 1, 1 - (2:2:m).^2 ];
      f = real(ifft([ c(1:n), c(m:-1:2) ]));
      weights = [ f(1), 2 * f(2:m), f(n) ];
      nodes = (-1) * cos(pi * (0:m) / m); % also flip

      %
      % We would like to compute integrals with respect to the density
      % of the uniform distribution on the interval [a, b]. However,
      % the computed nodes and weights are for the integrals on [-1, 1]
      % with the weight function equal to unity.
      %
      % See GaussLegendre for the needed transformation in this case.
      %
      a = this.distribution.a;
      b = this.distribution.b;

      nodes = ((nodes + 1) / 2) * (b - a) + a;
      weights = weights / sum(weights);
      % ... or weights / 2 in 1D.
    end
  end
end
