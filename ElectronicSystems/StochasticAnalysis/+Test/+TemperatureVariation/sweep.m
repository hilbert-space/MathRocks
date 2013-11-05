function sweep(varargin)
  setup;

  errorMetric = 'RMSE';

  options = Options(varargin{:});

  analysis = options.fetch('analysis', 'Transient');
  fprintf('Analysis: %s\n', analysis);

  options = Configure.systemSimulation(options);
  options = Configure.deterministicAnalysis(options);
  temperature = Temperature.Analytical.(analysis)(options);

  options = Configure.stochasticAnalysis(options);

  if options.has('surrogate')
    fprintf('Surrogate: %s\n', options.surrogate);
    surrogate = instantiate(options.surrogate, analysis, options);
    fprintf('Surrogate: construction...\n');
    time = tic;
    surrogateOutput = surrogate.compute(options.dynamicPower);
    fprintf('Surrogate: done in %.2f seconds.\n', toc(time));

    display(surrogate, surrogateOutput);
    if surrogate.inputCount <= 3, plot(surrogate, surrogateOutput); end

    process = surrogate.process;
  else
    process = ProcessVariation(options.processOptions);
  end

  Plot.powerTemperature(options.dynamicPower, [], ...
    temperature.compute(options.dynamicPower), ...
    'time', options.timeLine);

  function Tdata = evaluate(parameters)
    parameters = process.evaluate(parameters, true);
    parameters = process.assign(parameters);
    Tdata = permute(temperature.computeWithLeakage( ...
      options.dynamicPower, parameters), [ 3 1 2 ]);
  end

  parameters = options.processOptions.parameters;
  dimensions = process.dimensions;
  parameterCount = length(dimensions);
  names = fieldnames(parameters);

  sweeps = cell(1, parameterCount);
  nominals = cell(1, parameterCount);
  for i = 1:parameterCount
    sweeps{i} = linspace(sqrt(eps), 1 - sqrt(eps), 200);
    nominals{i} = 0.5 * ones(length(sweeps{i}), dimensions(i));
  end

  Iparameter = 1;
  Ivariable = 1;
  Istep = round(options.stepCount / 2);

  while true
    Iparameter = askParameter(names, Iparameter);
    if isempty(Iparameter)
      Iparameter = 1;
      continue;
    end

    Ivariable = askVariable(dimensions(Iparameter), Ivariable);
    if isempty(Ivariable)
      Ivariable = 1;
      continue;
    end

    Istep = askStep(options.stepCount, options.samplingInterval, Istep);
    if isempty(Istep)
      Istep = round(options.stepCount / 2);
      continue;
    end

    parameters = nominals;
    for i = Ivariable
      parameters{Iparameter}(:, i) = sweeps{Iparameter};
    end

    fprintf('Monte Carlo: evaluation...\n');
    time = tic;
    data = evaluate(parameters);
    fprintf('Monte Carlo: done in %.2f seconds.\n', toc(time));

    data = Utils.toCelsius(data(:, :, Istep));

    Plot.figure(800, 400);

    if ~exist('surrogate', 'var')
      for i = 1:options.processorCount
        Plot.line(sweeps{Iparameter}, data(:, i), 'number', i);
      end
    else
      fprintf('Surrogate: evaluation...\n');
      time = tic;
      surrogateData = surrogate.evaluate( ...
        surrogateOutput, cell2mat(parameters), true); % uniform
      fprintf('Surrogate: done in %.2f seconds.\n', toc(time));
      surrogateData = Utils.toCelsius(surrogateData(:, :, Istep));

      legend = {};
      for i = 1:options.processorCount
        Plot.line(sweeps{Iparameter}, ...
          abs(data(:, i) - surrogateData(:, i)), 'number', i);
        legend{end + 1} = sprintf('%s %.4f', errorMetric, ...
          Error.compute(errorMetric, data(:, i), surrogateData(:, i)));
      end

      Plot.title('Absolute error at %.3f s', ...
        Istep * options.samplingInterval);
      Plot.label(sprintf('%s(%s)', names{Iparameter}, ...
        String(Ivariable)), 'log(Absolute error, C)');
      Plot.legend(legend{:});

      set(gca, 'YScale', 'log');

      Plot.figure(800, 400);

      for i = 1:options.processorCount
        Plot.line(sweeps{Iparameter}, data(:, i), 'number', i);
        Plot.line(sweeps{Iparameter}, surrogateData(:, i), ...
          'auxiliary', true, 'style', { 'Color', 'k' });
      end
    end

    Plot.title('Temperature variation at %.3f s', ...
      Istep * options.samplingInterval);
    Plot.label(sprintf('%s(%s)', names{Iparameter}, ...
      String(Ivariable)), 'Temperature, C');

    if ~Console.question('Sweep more? '), break; end
  end
end

function index = askParameter(names, index)
  if length(names) == 1
    index = 1;
    return;
  end

  name = Console.request( ...
    'prompt', sprintf('Which parameter (%s)? [%s] ', ...
    String.join(', ', names), names{index}), ...
    'type', 'char', 'default', names{index});

  index = [];

  for i = 1:length(names)
    if strcmpi(names{i}, name)
      index = i;
      return;
    end
  end
end

function index = askVariable(dimensionCount, index)
  if dimensionCount == 1
    index = 1;
    return;
  end

  index = Console.request( ...
    'prompt', sprintf('Which random variable (up to %d)? [%s] ', ...
    dimensionCount, String(index)), 'default', index);

  if any(index > dimensionCount), index = []; end
end

function index = askStep(stepCount, samplingInterval, index)
  time = Console.request( ...
    'prompt', sprintf('What moment of time (up to %.2f s)? [%s] ', ...
    stepCount * samplingInterval, String(index * samplingInterval)), ...
    'default', index * samplingInterval);

  index = floor(time / samplingInterval);

  if index < 1 || index > stepCount, index = []; end
end
