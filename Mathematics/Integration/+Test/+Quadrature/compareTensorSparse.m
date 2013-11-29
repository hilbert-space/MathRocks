function compareTensorSparse(varargin)
  setup;

  options = Options( ...
    'dimensionCount', 3, ...
    'rule', 'GaussHermite', ...
    'level', 2, ...
    varargin{:});

  display(options, 'Quadrature');

  quadrature1 = Quadrature(options, 'method', 'tensor');
  quadrature2 = Quadrature(options, 'method', 'sparse');

  fprintf('Tensor nodes: %d\n', quadrature1.nodeCount);
  fprintf('Sparse nodes: %d\n', quadrature2.nodeCount);

  if options.dimensionCount > 3, return; end

  Plot.figure(1200, 600);
  Plot.name(options.rule);

  subplot(1, 2, 1);
  plot(quadrature1, 'figure', false);
  Plot.title('Tensor product (%d nodes)', quadrature1.nodeCount);

  subplot(1, 2, 2);
  plot(quadrature2, 'figure', false);
  Plot.title('Sparse grid (%d nodes)', quadrature2.nodeCount);
end
