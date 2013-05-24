function plot(this, varargin)
  assert(this.dimensionCount == 2);

  nodes = this.nodes;

  plot(nodes(:, 1), nodes(:, 2), ...
    'LineStyle', 'None', 'Marker', 'o', varargin{:});
  Plot.label('Dimension 1', 'Dimension 2');
end
