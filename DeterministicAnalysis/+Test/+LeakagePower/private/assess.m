function assess(varargin)
  options = Options(varargin{:});
  errorMetric = options.fetch('errorMetric', 'NRMSE');
  assessSpeed = options.fetch('assessSpeed', false);

  options = Configure.systemSimulation(options);
  options = Configure.deterministicAnalysis(options);

  options = options.leakageOptions;
  options.referencePower = NaN;

  leakageOne = LeakagePower(options);
  parameters = options.parameters;

  %
  % Accuracy
  %
  switch class(leakageOne.surrogate)
  case 'Fitting.Interpolation.Linear'
    plotLeakage(leakageOne, [], parameters);
  otherwise
    leakageTwo = LeakagePower( ...
      'circuit', options.circuit, 'parameters', parameters, ...
      'method', 'Interpolation', 'algorithm', 'Linear');

    parameterCount = length(parameters);
    grid = cell(1, parameterCount);
    for i = 1:parameterCount
      range = parameters.get(i).range;
      grid{i} = linspace(min(range), max(range), 50);
    end
    [ grid{:} ] = ndgrid(grid{:});

    I1 = leakageOne.evaluate(grid{:});
    I2 = leakageTwo.evaluate(grid{:});

    error = Error.compute(errorMetric, I2, I1);
    fprintf('%s: %.4f (%d points)\n', errorMetric, error, numel(I1));

    plotLeakage(leakageOne, leakageTwo, parameters);
  end

  if ~assessSpeed, return; end

  %
  % Speed
  %
  pointCount = 1e2;
  iterationCount = 1e2;

  parameterCount = leakageOne.parameterCount;
  parameterSweeps = leakageOne.parameterSweeps;

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
    leakageOne.evaluate(grids{:});
  end
  fprintf('Computational time: %.4f s\n', toc(time) / iterationCount);
end

function plotLeakage(leakageOne, leakageTwo, parameters, varargin)
  names = fieldnames(parameters);
  dimensionCount = length(names);

  normalization = struct;
  for i = 1:dimensionCount
    normalization.(names{i}) = parameters.(names{i}).nominal;
  end

  options = Options('logScale', true, ...
    'normalization', normalization, varargin{:});

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

    if isempty(leakageTwo)
      plot(leakageOne, options, 'fixedParameters', fixedParameters);
      colormap(flipud(hot));
    else
      Plot.figure(1200, 400);

      subplot(1, 2, 1);
      plot(leakageOne, options, 'figure', false, ...
        'fixedParameters', fixedParameters);
      colormap(flipud(hot));

      subplot(1, 2, 2);
      plot(leakageTwo, options, 'figure', false, ...
        'fixedParameters', fixedParameters);
      colormap(flipud(hot));
    end
  end
end
