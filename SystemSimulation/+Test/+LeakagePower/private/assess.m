function assess(fittingMethod, varargin)
  setup;

  options = Options( ...
    'fittingMethod', fittingMethod, ...
    'filename', File.join('+Test', 'Assets', 'inverter_08.leak'), ...
    'countConstraints', struct( ...
      'name', { 'T', 'Leff' }, 'count', { 51, 51 }), ...
    'rangeConstraints', struct( ...
      'name', { 'T' }, 'range', { Utils.toKelvin([ 0, 500 ]) }), ...
    varargin{:});

  leakage = LeakagePower(options);
  plot(leakage);

  if ~options.get('assessSpeed', false), return; end

  pointCount = 1e3;
  iterationCount = 1e2;

  dimensionCount = leakage.fit.dimensionCount;
  sweeps = leakage.fit.sweeps;

  for i = 1:dimensionCount
    sweeps{i} = linspace(min(sweeps{i}), max(sweeps{i}), pointCount);
  end

  grids = cell(1, dimensionCount);
  [ grids{:} ] = ndgrid(sweeps{:});

  time = tic;
  for k = 1:iterationCount
    leakage.compute(grids);
  end
  fprintf('Computational time: %.4f s\n', toc(time) / iterationCount);
end
