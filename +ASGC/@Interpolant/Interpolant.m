classdef Interpolant < handle
  properties (SetAccess = 'private')
    dimension
    maxLevel

    nodes
    weights
    index
    map
  end

  methods
    function this = Interpolant(f, varargin)
      options = Options(varargin{:});
      this.initialize(f, options);
    end

    function plot(this)
      assert(this.dimension == 2, ...
        'Only the two-dimensional case is supported.');
      line(this.nodes(:, 1), this.nodes(:, 2), ...
        'LineStyle', 'none', 'Marker', 'o');
    end

    result = compute(this, nodes)
  end

  methods (Access = 'private')
    [ nodes, weights, index, map ] = construct(this, f, options)
    count = countNodes(this, level)
    values = computeNodes(this, level, count)
    values = computeWavelet(this, index, node, newNode)

    function initialize(this, f, options)
      this.dimension = options.dimension;
      this.maxLevel = options.maxLevel;

      [ this.nodes, this.weights, this.index, this.map ] = ...
        this.construct(f, options);
    end
  end
end
