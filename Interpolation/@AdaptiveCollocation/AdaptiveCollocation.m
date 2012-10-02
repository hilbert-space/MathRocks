classdef AdaptiveCollocation < handle
  properties (SetAccess = 'protected')
    nodes
  end

  methods
    function this = AdaptiveCollocation(f, varargin)
      options = Options(varargin{:});
      this.initialize(f, options);
    end

    function plot(this)
      nodes = this.nodes;

      dimensionCount = size(nodes, 2);
      assert(dimensionCount == 2, ...
        'Only two-dimensional grids are supported.');

      plot(nodes(:, 1), nodes(:, 2), ...
        'Marker', '.', 'Color', 'k', 'LineStyle', 'None');
    end

    function display(this)
      [ nodeCount, dimensionCount ] = size(this.nodes);

      fprintf('Adaptive sparse grid collocation:\n');
      fprintf('  Dimensions: %d\n', dimensionCount);
      fprintf('  Nodes:      %d\n', nodeCount);
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)

    function initialize(this, f, options)
      this.construct(f, options);
    end
  end
end
