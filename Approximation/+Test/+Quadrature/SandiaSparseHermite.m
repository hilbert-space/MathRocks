clear all;
setup;

dimensionCount = 2;
level = 3;
order = 6;
rule = 6;

subplot(1, 2, 1);
color = Color.pick(1);

grid = Quadrature( ...
  'method', 'sparse', ...
  'dimensionCount', dimensionCount, ...
  'order', order, ...
  'ruleName', 'GaussHermiteHW');

plot(grid, 'Color', color, 'MarkerFaceColor', color, ...
  'Marker', 'o', 'MarkerSize', 5);
Plot.title('Sparse grid with %d nodes', grid.nodeCount);

subplot(1, 2, 2);
color = Color.pick(2);

nodeCount = levels_index_size(dimensionCount, level, rule);
[ ~, nodes ] = sparse_grid(dimensionCount, level, rule, nodeCount);

plot(nodes(1, :), nodes(2, :), 'Color', color, 'LineStyle', 'None', ...
  'MarkerFaceColor', color, 'Marker', 'o', 'MarkerSize', 5);

Plot.label('Dimension 1', 'Dimension 2');
Plot.title('Sparse grid with %d nodes', nodeCount);
