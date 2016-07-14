function compareIsotropicAnisotropic(varargin)
  setup;

  options = Options( ...
    'dimensionCount', 3, ...
    'rule', 'GaussHermite', ...
    'method', 'sparse', ...
    'level', 3, ...
    varargin{:});

  display(options, 'Quadrature');

  quadrature1 = Quadrature(options);
  quadrature2 = Quadrature(options, 'anisotropy', [0.5, 1, 1]);

  fprintf('Isotropic nodes:   %d\n', quadrature1.nodeCount);
  fprintf('Anisotropic nodes: %d\n', quadrature2.nodeCount);

  if options.dimensionCount > 3, return; end

  Plot.figure(1200, 600);
  Plot.name(options.rule);

  subplot(1, 2, 1);
  plot(quadrature1, 'figure', false);
  Plot.title('Isotropic sparse grid (%d nodes)', quadrature1.nodeCount);

  subplot(1, 2, 2);
  plot(quadrature2, 'figure', false);
  Plot.title('Anisotropic sparse grid (%d nodes)', quadrature2.nodeCount);
end
