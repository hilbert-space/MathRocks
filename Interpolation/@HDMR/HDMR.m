classdef HDMR < handle
  properties (SetAccess = 'private')
    inputDimension
    outputDimension

    order
    nodeCount

    offset
    interpolants
  end

  methods
    function this = HDMR(f, varargin)
      options = Options(varargin{:});
      this.construct(f, options);
    end

    function display(this)
      fprintf('High-dimensional model representation:\n');
      fprintf('  Input dimension:  %d\n', this.inputDimension);
      fprintf('  Output dimension: %d\n', this.outputDimension);
      fprintf('  Order:            %d\n', this.order);
      fprintf('  Nodes:            %d\n', this.nodeCount);
      fprintf('  Interpolants:     %d\n', length(this.interpolants));
    end
  end

  methods (Access = 'protected')
    construct(this, f, options)
  end
end
