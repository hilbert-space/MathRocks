clear all;
setup;

dimensionCount = 2;
order = 5;

grid = Quadrature( ...
  'method', 'sparse', ...
  'dimensionCount', dimensionCount, ...
  'order', order, ...
  'ruleName', 'GaussHermite');

f = @(l) nwspgr('gqn', 1, l);

[ nodes, weights ] = nwspgr(f, dimensionCount, order);
points = length(weights);

fprintf('Expected points: %d\n', points);
fprintf('Computed points: %d\n', grid.nodeCount);

fprintf('Nodes:\n');
for i = 1:min(points, grid.nodeCount)
  fprintf('%3d ', i);
  for j = 1:dimensionCount
    fprintf('| %10.4f - %10.4f = %10.4f', ...
      grid.nodes(i, j), nodes(i, j), grid.nodes(i, j) - nodes(i, j));
  end
  fprintf('\n');
end

fprintf('Weights:\n');
for i = 1:min(points, grid.nodeCount)
  fprintf('%3d ', i);
  fprintf('| %10.4f - %10.4f = %10.4f', ...
    grid.weights(i), weights(i), grid.weights(i) - weights(i));
  fprintf('\n');
end

fprintf('Infinity norm of nodes: %e\n', ...
  norm(nodes - grid.nodes, Inf));
fprintf('Infinity norm of weights: %e\n', ...
  norm(weights - grid.weights, Inf));
