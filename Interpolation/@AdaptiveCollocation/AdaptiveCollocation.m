classdef AdaptiveCollocation < handle
  properties (SetAccess = 'protected')
    dimensionCount
    nodeCount
    lastNodeCount
    nodes
  end

  methods
    function this = AdaptiveCollocation(f, varargin)
      options = Options(varargin{:});
      this.initialize(f, options);
    end

    function plot(this)
      assert(this.dimensionCount == 2, ...
        'Only two-dimensional grids are supported.');

      line( ...
        this.nodes(1:(this.nodeCount - this.lastNodeCount), 1), ...
        this.nodes(1:(this.nodeCount - this.lastNodeCount), 2), ...
        'Marker', '.', 'Color', 'k', 'LineStyle', 'None');
      line( ...
        this.nodes((this.nodeCount - this.lastNodeCount + 1):end, 1), ...
        this.nodes((this.nodeCount - this.lastNodeCount + 1):end, 2), ...
        'Marker', '.', 'Color', 'r', 'LineStyle', 'None');
    end

    function display(this)
      fprintf('Adaptive sparse grid collocation:\n');
      fprintf('  Dimensions: %d\n', this.dimensionCount);
      fprintf('  Nodes:      %d\n', this.nodeCount);
      fprintf('  Last nodes: %d\n', this.lastNodeCount);
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)

    function initialize(this, f, options)
      this.construct(f, options);
    end
  end
end
