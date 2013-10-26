classdef GaussHermite < Quadrature.Base
  methods
    function this = GaussHermite(varargin)
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

      [ nodes, weights ] = hermite_compute(order);

      %
      % The computed nodes and weights can be used to evaluate integrals with
      % the weight function
      %
      % exp(-y^2).
      %
      % However, we need the standard Gaussian weight, i.e.,
      %
      %       1            x^2
      % ------------ exp(- ---).
      % sqrt(2 * pi)        2
      %
      % Therefore, we transform the nodes as
      %
      nodes = sqrt(2) * nodes;
      %
      % and the weights as
      %
      % weights = sqrt(2) * weights / sqrt(2 * pi);
      %
      % which can be simplified to:
      %
      weights = weights / sqrt(pi);
    end
  end
end
