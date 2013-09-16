function assess(fittingMethod, varargin)
  setup;

  options = Options( ...
    'fittingMethod', fittingMethod, ...
    'filename', File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_07.leak'), ...
    'countConstraints', struct( ...
      'parameter', { 'T', 'Leff' }, 'count', { 51, 51 }), ...
    'rangeConstraints', struct( ...
      'parameter', { 'T' }, 'range', { Utils.toKelvin([ 0, 500 ]) }), ...
    varargin{:});

  leakage = LeakagePower(options);
  plot(leakage);

  if ~options.get('assessSpeed', false), return; end

  pointCount = 1e3;
  iterationCount = 1e2;

  parameterCount = leakage.parameterCount;
  parameterSweeps = leakage.fit.parameterSweeps;

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
