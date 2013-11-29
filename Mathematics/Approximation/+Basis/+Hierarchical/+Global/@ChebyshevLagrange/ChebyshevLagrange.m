classdef ChebyshevLagrange < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    quadratureNodes
    barycentricWeights
  end

  methods
    function this = ChebyshevLagrange(varargin)
      this = this@Basis.Hierarchical.Global.Base(varargin{:});
    end
  end

  methods (Access = 'protected')
    function [ nodes, weights ] = configure(this, ~)
      if this.maximalLevel > 20
        warning('The maximal level is too high; changing to 10.');
        this.maximalLevel = 20;
      end

      level = this.maximalLevel;

      this.quadratureNodes = cell(1, level);
      this.barycentricWeights = cell(1, level);

      nodes = cell(1, level);
      weights = cell(1, level);

      for i = 1:level
        %
        % NOTE: Observe the difference in the level enumeration.
        %
        quadrature = Quadrature.ClenshawCurtis( ...
          'level', i - 1, 'growth', 'full-exponential');
        this.quadratureNodes{i} = quadrature.nodes;
        this.barycentricWeights{i} = ...
          [ 0.5, ones(1, quadrature.nodeCount - 2), 0.5 ] .* ...
          (-1).^double(0:(quadrature.nodeCount - 1));

        %
        % Extract the nodes and weights that belong to the current
        % _hierarchical_ level.
        %
        if i == 1
          I = 1;
        elseif i == 2
          I = [ 1 3 ];
        else
          I = (1:2^(i - 2)) * 2;
        end

        nodes{i} = quadrature.nodes(I);
        weights{i} = quadrature.weights(I);
      end
    end
  end
end
