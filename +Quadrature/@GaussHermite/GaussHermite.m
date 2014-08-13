classdef GaussHermite < Quadrature.Base
  methods
    function this = GaussHermite(varargin)
      this = this@Quadrature.Base('distribution', ...
        ProbabilityDistribution.Gaussian, varargin{:});
    end
  end

  methods (Access = 'protected')
    function [nodes, weights] = rule(this, order)
      [nodes, weights] = hermite_compute(order);

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
      mu = this.distribution.mu;
      sigma = this.distribution.sigma;

      nodes = mu + sqrt(2) * sigma * nodes;
      weights = weights / sum(weights);
      % ... or weights / sqrt(pi) in 1D.
    end
  end
end
