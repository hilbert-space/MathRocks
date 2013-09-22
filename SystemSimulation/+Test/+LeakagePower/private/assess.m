function assess(varargin)
  setup;

  options = Options(varargin{:});
  errorMetric = options.fetch('errorMetric', 'NRMSE');
  assessSpeed = options.fetch('assessSpeed', false);

  options = Configure.systemSimulation(options);
  options = options.leakageOptions;

  approximation = options.approximation;

  leakage = LeakagePower(options);

  %
  % Accuracy
  %
  switch approximation
  case 'Interpolation.Linear'
    plotLeakage(leakage);
  otherwise
    options = Options(options, ...
      'approximation', 'Interpolation.Linear', ...
      'countConstraints', Options( ...
        'T', 50, 'Leff', 50), ...
      'rangeConstraints', Options( ...
        'T', Utils.toKelvin([ 40, 400 ]), ...
        'Leff', [ -Inf, Inf ]));

    referenceLeakage = LeakagePower(options);

    grid = Grid(options, 'targetName', 'I');
    Iref = referenceLeakage.compute(grid.parameterData{:});
    Ipred = leakage.compute(grid.parameterData{:});

    error = Error.compute(errorMetric, Iref, Ipred);

    Plot.figure(1200, 400);
    Plot.name('%s: %s %.4f', approximation, errorMetric, error);

    subplot(1, 2, 1);
    plotLeakage(referenceLeakage, 'figure', false);
    Plot.title('Interpolation.Linear');

    subplot(1, 2, 2);
    plotLeakage(leakage, 'figure', false, 'grid', grid);
    Plot.title(approximation);
  end

  if ~assessSpeed, return; end

  %
  % Speed
  %
  pointCount = 1e2;
  iterationCount = 1e2;

  parameterCount = leakage.parameterCount;
  parameterSweeps = leakage.parameterSweeps;

  for i = 1:parameterCount
    parameterSweeps{i} = linspace( ...
      min(parameterSweeps{i}), ...
      max(parameterSweeps{i}), ...
      pointCount);
  end

  grids = cell(1, parameterCount);
  [ grids{:} ] = ndgrid(parameterSweeps{:});

  time = tic;
  for k = 1:iterationCount
    leakage.compute(grids{:});
  end
  fprintf('Computational time: %.4f s\n', toc(time) / iterationCount);
end

function plotLeakage(leakage, varargin)
  plot(leakage, 'parameters', struct('Tox', 1.25e-9), varargin{:});
end
