classdef GaussHermite < Quadrature.Base
  methods
    function this = GaussHermite(varargin)
      this = this@Quadrature.Base( ...
        'distribution', ProbabilityDistribution.Gaussian, ...
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

      mu = this.distribution.mu;
      sigma = this.distribution.sigma;

      [ nodes, weights ] = hermite_compute(order);

      %
      % We would like to compute integrals with respect to
      % the densities of Gaussian distributions:
      %
      %                             +oo
      %                   1          /               (x - mu)^2
      %  g(x) = -------------------- | h(x) * exp(- -----------) * dx.
      %         sqrt(2 * pi) * sigma /              2 * sigma^2
      %                             -oo
      %
      % However, the computed nodes and weights are for the integrals
      % of the following form:
      %
      %         +oo
      %          /
      %  g(y) =  | h(y) * exp(- y^2) * dy.
      %          /
      %         -oo
      %
      % Therefore, we use the following change of variables:
      %
      %           x - mu
      %  y = ---------------,
      %      sqrt(2) * sigma
      %
      %  x = mu + sqrt(2) * sigma * y,
      %
      %  dx = sqrt(2) * sigma * dy.
      %
      nodes = mu + sqrt(2) * sigma * nodes;
      weights = weights / sqrt(pi);
    end
  end
end
