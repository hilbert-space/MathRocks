function sweep(varargin)
  setup;

  options = Options(varargin{:});

  analysis = options.fetch('analysis', 'Transient');
  fprintf('Analysis: %s\n', analysis);

  options = Configure.systemSimulation(options);
  temperature = Temperature.Analytical.(analysis)(options);

  options = Configure.processVariation(options);

  if options.has('surrogate')
    fprintf('Surrogate: %s\n', options.surrogate);
    options = Configure.temperatureVariation(options);
    surrogate = Utils.instantiate(String.join('.', ...
      'TemperatureVariation', options.surrogate, analysis), options);
    fprintf('Surrogate: construction...\n');
    time = tic;
    surrogateOutput = surrogate.compute(options.dynamicPower);
    fprintf('Surrogate: done in %.2f seconds.\n', toc(time));

    display(surrogate, surrogateOutput);

    process = surrogate.process;
  else
    process = ProcessVariation(options.processOptions);
  end

  Plot.powerTemperature(options.dynamicPower, [], ...
     temperature.compute(options.dynamicPower), ...
    'time', options.timeLine);

  function Tdata = evaluate(parameters)
    parameters = process.evaluate(parameters, true);
    parameters = cellfun(@transpose, parameters, 'UniformOutput', false);
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
    Tdata = evaluate(parameters);
    fprintf('Monte Carlo: done in %.2f seconds.\n', toc(time));

    Tdata = Utils.toCelsius(Tdata(:, :, Istep));

    Plot.figure(800, 400);

    if ~exist('surrogate', 'var')
      for i = 1:options.processorCount
        Plot.line(sweeps{Iparameter}, Tdata(:, i), 'number', i);
      end
    else
      fprintf('Surrogate: evaluation...\n');
      time = tic;
      surrogateTdata = surrogate.evaluate( ...
        surrogateOutput, cell2mat(parameters), true); % uniform
      fprintf('Surrogate: done in %.2f seconds.\n', toc(time));
      surrogateTdata = Utils.toCelsius(surrogateTdata(:, :, Istep));

      for i = 1:options.processorCount
        Plot.line(sweeps{Iparameter}, Tdata(:, i), 'number', i);
        Plot.line(sweeps{Iparameter}, surrogateTdata(:, i), ...
          'number', i, 'auxiliary', true);
      end
    end

    Plot.title('Sweep at %.3f s', Istep * options.samplingInterval);
    Plot.label(sprintf('%s(%s)', names{Iparameter}, String(Ivariable)), ...
      'Temperature, C');

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
