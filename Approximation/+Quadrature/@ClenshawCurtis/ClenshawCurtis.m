classdef ClenshawCurtis < Quadrature.Base
  methods
    function this = ClenshawCurtis(varargin)
      this = this@Quadrature.Base( ...
        'distribution', ProbabilityDistribution.Uniform, ...
        'growth', 'full-exponential', varargin{:});

      %
      % NOTE: Only one growth rule is supported for now.
      %
      assert(strcmpi(this.growth, 'full-exponential'));
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(this, level)
      a = this.distribution.a;
      b = this.distribution.b;

      if level == 0 % special case
        nodes = (b - a) / 2;
        weights = 2 / 2;
        return;
      end

      %
      % Reference:
      %
      % http://people.sc.fsu.edu/~jburkardt/m_src/sparse_grid_cc/sparse_grid_cc.html
      %
      n = 2^level + 1;

      %
      % Reference:
      %
      % J. Waldvogel. Fast Construction of the Fejer and Clenshaw-Curtis
      % Quadrature Rules. BIT Numerical Mathematics. March 2006, Volume 46,
      % Issue 1, pp. 195--202.
      %
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
      nodes = ((nodes + 1) / 2) * (b - a) + a;
      weights = weights / 2;
    end
  end
end
