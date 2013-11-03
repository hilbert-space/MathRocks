classdef GaussJacobi < Quadrature.Base
  methods
    function this = GaussJacobi(varargin)
      this = this@Quadrature.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = rule(~, level, options)
      %
      % First, we determine the growth rule.
      %
      % Reference:
      %
      % http://people.sc.fsu.edu/~jburkardt/cpp_src/sgmg/sgmg.html
      %
      growth = options.get('growth', 'slow-linear');
      if isa(growth, 'function_handle')
        order = feval(growth, level);
      elseif strcmpi(growth, 'slow-linear')
        order = level + 1;
      elseif strcmpi(growth, 'full-exponential')
        order = 2^(level + 1) - 1;
      else
        assert(false);
      end

      [ nodes, weights ] = jacobi_compute(order, options.alpha, options.beta);

      %
      % For some reason, the nodes are returned as a row vector.
      %
      nodes = nodes(:);

      %
      % The computed nodes and weights can be used to evaluate integrals
      % with the weight function equal to
      %
      % (1 - y)^alpha * (1 + y)^beta
      %
      % where the integration goes from -1 to 1. However, we need the
      % four-parameter beta weight, i.e.,
      %
      %            (x - a)^alpha * (b - x)^beta
      % ------------------------------------------------------
      % (b - a)^(alpha + beta + 1) * Beta(alpha + 1, beta + 1)
      %
      % where the integration is from a to b.
      %
      % NOTE: There is a difference in the exponents between the Jacobi
      % polynomials (J) and the standard beta distribution (B); to be
      % specific, we have alpha(J) = alpha(B) - 1, beta(J) = beta(B) - 1.
      %
      % All in all,
      %
      nodes = ((nodes + 1) / 2) * (options.b - options.a) + options.a;
      weights = weights / ((options.b - options.a)^(options.alpha + ...
        options.beta + 1) * beta(options.alpha + 1, options.beta + 1));
    end
  end
end
