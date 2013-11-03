function assess(varargin)
  setup;

  options = Options(varargin{:});
  errorMetric = options.fetch('errorMetric', 'NRMSE');
  assessSpeed = options.fetch('assessSpeed', false);

  options = Configure.systemSimulation(options);
  options = options.leakageOptions;

  method = options.method;

  leakage = LeakagePower(options);
  parameters = options.parameters;

  %
  % Accuracy
  %
  switch method
  case 'Interpolation.Linear'
    plotLeakage(leakage, parameters);
  otherwise
    referenceLeakage = LeakagePower( ...
      'filename', options.filename, 'parameters', parameters, ...
      'method', 'Interpolation.Linear');

    grid = Grid(options, 'targetName', 'Ileak');
    Iref = referenceLeakage.compute(grid.parameterData{:});
    Ipred = leakage.compute(grid.parameterData{:});

    error = Error.compute(errorMetric, Iref, Ipred);

    Plot.figure(1200, 400);
    Plot.name('%s: %s %.4f', method, errorMetric, error);

    subplot(1, 2, 1);
    plotLeakage(referenceLeakage, parameters, 'figure', false);
    Plot.title('Interpolation.Linear');

    subplot(1, 2, 2);
    plotLeakage(leakage, parameters, 'figure', false, 'grid', grid);
    Plot.title(method);
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

function plotLeakage(leakage, parameters, varargin)
  names = fieldnames(parameters);
  dimensionCount = length(names);

  normalization = struct;
  for i = 1:dimensionCount
    normalization.(names{i}) = parameters.(names{i}).nominal;
  end

  combinations = [ ...
    mat2cell(1:dimensionCount, ...
      1, ones(1, dimensionCount)), ...
    mat2cell(combnk(1:dimensionCount, 2), ...
      ones(1, nchoosek(dimensionCount, 2)), 2).' ];

  for i = 1:length(combinations)
    fixedParameters = struct;
    for j = setdiff(1:dimensionCount, combinations{i})
      fixedParameters.(names{j}) = parameters.(names{j}).nominal;
    end

    plot(leakage, 'logScale', true, 'normalization', normalization, ...
      'fixedParameters', fixedParameters, varargin{:});
    colormap(flipud(hot));
  end
end
