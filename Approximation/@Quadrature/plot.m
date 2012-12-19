function plot(this, varargin)
  dimension = this.dimension;

  assert(dimension == 2);

  nodes = this.nodes;
  nodeCount = this.nodeCount;

  plot(nodes(:, 1), nodes(:, 2), ...
    'LineStyle', 'None', 'Marker', 'o', varargin{:});
  Plot.label('Dimension 1', 'Dimension 2');
end
