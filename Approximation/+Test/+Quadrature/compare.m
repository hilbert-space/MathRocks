function compare(varargin)
  setup;

  options = Options('rule', 'GaussHermite', ...
    'dimensionCount', 3, 'order', 5, varargin{:});

  rule = options.fetch('rule');

  display(options, 'Quadrature');

  quadrature1 = Quadrature.(rule)( ...
    options, 'method', 'tensor');

  quadrature2 = Quadrature.(rule)( ...
    options, 'method', 'sparse');

  fprintf('Tensor-product nodes: %d\n', quadrature1.nodeCount);
  fprintf('Sparse-grid nodes:    %d\n', quadrature2.nodeCount);

  if options.dimensionCount > 3, return; end

  Plot.figure(1200, 600);
  Plot.name(rule);

  subplot(1, 2, 1);
  Plot.quadrature(quadrature1.nodes, quadrature1.weights, 'figure', false);
  Plot.title('Tensor with %d nodes', quadrature1.nodeCount);

  subplot(1, 2, 2);
  Plot.quadrature(quadrature2.nodes, quadrature2.weights, 'figure', false);
  Plot.title('Sparse with %d nodes', quadrature2.nodeCount);
end
