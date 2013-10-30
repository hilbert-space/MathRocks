classdef ChebyshevGaussLobattoLagrange < Basis.Hierarchical.Global.Base
  properties (SetAccess = 'private')
    quadratureNodes
    quadratureOrders

    nodes
    weights
    counts
  end

  methods
    function this = ChebyshevGaussLobattoLagrange(varargin)
      options = Options(varargin{:});

      this = this@Basis.Hierarchical.Global.Base(options);

      if this.maximalLevel > 10
        warning('The maximal level is too high; changing to 10.');
        this.maximalLevel = 10;
      end

      this.quadratureNodes = cell(1, this.maximalLevel);
      this.quadratureOrders = zeros(1, this.maximalLevel, 'uint32');

      this.nodes = cell(1, this.maximalLevel);
      this.weights = cell(1, this.maximalLevel);
      this.counts = zeros(1, this.maximalLevel, 'uint32');

      for level = 1:this.maximalLevel
        %
        % NOTE: Observe the difference in the level enumeration.
        %
        quadrature = Quadrature.ChebyshevGaussLobatto('level', level - 1);
        this.quadratureNodes{level} = quadrature.nodes;
        this.quadratureOrders(level) = quadrature.nodeCount;

        %
        % Extract the nodes and weights that belong to the current
        % _hierarchical_ level.
        %
        if level == 1
          I = 1;
        elseif level == 2
          I = [ 1 3 ];
        else
          I = (1:2^(level - 2)) * 2;
        end

        this.nodes{level} = quadrature.nodes(I);
        this.weights{level} = quadrature.weights(I);
        this.counts(level) = numel(this.nodes{level});
      end
    end
  end
end
