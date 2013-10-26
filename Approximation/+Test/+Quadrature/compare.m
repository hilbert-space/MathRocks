function compare(varargin)
  setup;

  options = Options( ...
    'dimensionCount', 3, ...
    'rule', 'GaussHermite', ...
    'level', 2, ...
    varargin{:});

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
  plot(quadrature1, 'figure', false);
  Plot.title('Tensor-product quadrature (%d nodes)', quadrature1.nodeCount);

  subplot(1, 2, 2);
  plot(quadrature2, 'figure', false);
  Plot.title('Sparse-grid quadrature (%d nodes)', quadrature2.nodeCount);
end
