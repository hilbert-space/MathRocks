classdef NewtonCotes < Quadrature.Base
  methods
    function this = NewtonCotes(varargin)
      this = this@Quadrature.Base('distribution', ...
        ProbabilityDistribution.Uniform, varargin{:});
    end
  end

  methods (Access = 'protected')
    function order = computeOrder(this, level)
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

    function [nodes, weights] = rule(this, order)
      if order == 1 % special case
        nodes = 0.5;
        weights = 1;
        return;
      end

      nodes = (0:(order - 1)) / (order - 1);
      weights = ones(1, order);

      a = this.distribution.a;
      b = this.distribution.b;

      nodes = nodes * (b - a) + a;
      weights = weights / sum(weights);
      % ... or weights / 2 in 1D.
    end
  end
end
