classdef AdaptiveCollocation < handle
  properties (SetAccess = 'protected')
    dimensionCount
    nodeCount
    lastNodeCount
    nodes

    evaluationNodes
    evaluationIntervals
    surpluses
  end

  methods
    function this = AdaptiveCollocation(f, varargin)
      options = Options(varargin{:});
      this.initialize(f, options);
    end

    function plot(this)
      assert(this.dimensionCount == 2, ...
        'Only two-dimensional grids are supported.');

      nodes = this.nodes;

      line( ...
        nodes(1:(this.nodeCount - this.lastNodeCount), 1), ...
        nodes(1:(this.nodeCount - this.lastNodeCount), 2), ...
        'Marker', '.', 'MarkerSize', 10, ...
        'Color', [ 1 1 1 ] / 6, 'LineStyle', 'None');
      line( ...
        nodes((this.nodeCount - this.lastNodeCount + 1):end, 1), ...
        nodes((this.nodeCount - this.lastNodeCount + 1):end, 2), ...
        'Marker', '.', 'MarkerSize', 10, ...
        'Color', 'r', 'LineStyle', 'None');
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
