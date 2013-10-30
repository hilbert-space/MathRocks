classdef ClenshawCurtis < Quadrature.Base
  methods
    function this = ClenshawCurtis(varargin)
      this = this@Quadrature.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(~, level, options)
      if level == 0
        nodes = 0.5;
        weights = 1;
        return;
      end

      %
      % NOTE: Let us support only one growth rule for now.
      %
      if options.has('growth')
        assert(strcmpi(options.growth, 'full-exponential'));
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

      x = cos(pi * (0:m) / m);

      c = zeros(1, n);
      c(1:2:n) = 2 ./ [ 1, 1 - (2:2:m).^2 ];
      f = real(ifft([ c(1:n), c(m:-1:2) ]));
      w = [ f(1), 2 * f(2:m), f(n) ];

      %
      % The computed nodes and weights are for the integration on [-1, 1];
      % however, we would like to work on the standard interval [0, 1].
      %
      nodes = (-x + 1) / 2;
      weights = w / 2;
    end
  end
end
