classdef GaussLegendre < Quadrature.Base
  methods
    function this = GaussLegendre(varargin)
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
      switch options.get('growth', 'slow-linear')
      case 'slow-linear'
        order = level + 1;
      case 'full-exponential'
        order = 2^(level + 1) - 1;
      otherwise
        assert(false);
      end

      [ nodes, weights ] = legendre_compute(order);

      %
      % The computed nodes and weights can be used to evaluate integrals
      % on the interval [-1, 1] with the weight function equal to one.
      % However, we would like to integrate on [a, b] with the weight
      % of the uniform ditribution on [a, b]. So,
      %
      nodes = ((nodes + 1) / 2) * (options.b - options.a) + options.a;
      weights = weights / (options.b - options.a);
    end
  end
end
