setup;

dimension = 2;
level = 5;

grid = Quadrature.Sparse( ...
  'dimension', dimension, 'level', level, ...
  'rules', 'GaussHermite');

f = @(l) nwspgr('gqn', 1, l);

[ nodes, weights ] = nwspgr(f, dimension, level);
points = length(weights);

fprintf('Expected points: %d\n', points);
fprintf('Computed points: %d\n', grid.points);

fprintf('Infinity norm of nodes: %e\n', ...
  norm(nodes - grid.nodes, Inf));
fprintf('Infinity norm of weights: %e\n', ...
  norm(weights - grid.weights, Inf));
