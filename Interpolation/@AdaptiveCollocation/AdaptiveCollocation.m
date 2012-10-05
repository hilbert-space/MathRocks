classdef AdaptiveCollocation < handle
  properties (SetAccess = 'protected')
    dimensionCount

    level
    nodeCount
    levelNodeCount

    nodes
    levelIndex

    surpluses
  end

  methods
    function this = AdaptiveCollocation(f, varargin)
      options = Options(varargin{:});
      this.initialize(f, options);
    end

    function display(this)
      fprintf('Adaptive sparse grid collocation:\n');
      fprintf('  Dimensions: %d\n', this.dimensionCount);
      fprintf('  Level:      %d\n', this.level);
      fprintf('  Nodes:      %d\n', this.nodeCount);
      fprintf('  Last nodes: %d\n', this.levelNodeCount(end));
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)

    function initialize(this, f, options)
      this.construct(f, options);
    end
  end
end
