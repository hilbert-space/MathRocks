function assess(fittingMethod, varargin)
  setup;

  options = Options( ...
    'fittingMethod', fittingMethod, ...
    'filename', File.join('+Test', 'Assets', ...
      'inverter_09_T(0,500)_Leff(-5,5)_Tox(-5,5).leak'), ...
    varargin{:});

  assessSpeed = options.fetch('assessSpeed', false);

  leakage = LeakagePower(options);
  plot(leakage, 'parameters', struct('Tox', 1.25e-9));

  if ~assessSpeed, return; end

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
