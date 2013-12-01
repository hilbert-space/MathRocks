function sweep(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);
  options = Configure.stochasticAnalysis(options);

  lowerBound = 0;
  upperBound = 1;
  errorMetric = 'Inf';

  if  options.get('compare', false)
    surrogate = TemperatureVariation(options);
    fprintf('Surrogate: %s\n', class(surrogate));
    fprintf('%s: construction...\n', class(surrogate));
    time = tic;
    surrogateOutput = surrogate.compute(options.dynamicPower);
    fprintf('%s: done in %.2f seconds.\n', class(surrogate), toc(time));

    display(surrogate, surrogateOutput);
    if surrogate.inputCount <= 3, plot(surrogate, surrogateOutput); end

    process = surrogate.process;

    if isa(surrogate.surrogate.distribution, 'ProbabilityDistribution.Gaussian')
      lowerBound = max(sqrt(eps), lowerBound);
      upperBound = min(1 - sqrt(eps), upperBound);
    end
  else
    process = ProcessVariation(options.processOptions);
  end

  temperature = Temperature(options.temperatureOptions);

  T = temperature.compute(options.dynamicPower);
  plot(temperature, T, 'time', options.timeLine);

  function Tdata = evaluate(parameters)
    parameters = process.evaluate(parameters, true);
    parameters = process.assign(parameters);
    Tdata = permute(temperature.computeWithLeakage( ...
      options.dynamicPower, parameters), [ 3 1 2 ]);
  end

  parameters = options.processOptions.parameters;
  parameterCount = length(parameters);
  dimensions = process.dimensions;

  sweeps = cell(1, parameterCount);
  nominals = cell(1, parameterCount);
  for i = 1:parameterCount
    sweeps{i} = linspace( ...
      max(lowerBound, sqrt(eps)), ...
      min(upperBound, 1 - sqrt(eps)), 200);
    nominals{i} = 0.5 * ones(length(sweeps{i}), dimensions(i));
  end

  parameterLine = sweeps{1}; % for simplicity

  [ ~, Imax ] = max(max(T, [], 1)); Imax = Imax(1);

  Iparameter = 1;
  Ivariable = num2cell(ones(1, parameterCount));
  Istep = Imax;

  while true
    Iparameter = askInteger('parameters', parameterCount, Iparameter);
    if isempty(Iparameter)
      Iparameter = 1;
      continue;
    end

    for i = Iparameter
      Ivariable{i} = askInteger([ 'variables for Parameter ', ...
        num2str(i) ], dimensions(i), Ivariable{i});
      if isempty(Ivariable{i})
        Ivariable{i} = 1;
        continue;
      end
    end

    Istep = askInteger('time step', options.stepCount, Istep);
    if isempty(Istep) || ~isscalar(Istep)
      Istep = Imax;
      continue;
    end

    parameters = nominals;
    for i = Iparameter
      for j = Ivariable{i}
        parameters{i}(:, j) = sweeps{i};
      end
    end

    fprintf('Monte Carlo: evaluation...\n');
    time = tic;
    data = evaluate(parameters);
    fprintf('Monte Carlo: done in %.2f seconds.\n', toc(time));

    data = Utils.toCelsius(data(:, :, Istep));

    Plot.figure(800, 400);

    if ~exist('surrogate', 'var')
      for i = 1:options.processorCount
        Plot.line(parameterLine, data(:, i), 'number', i);
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
        Plot.line(parameterLine, ...
          abs(data(:, i) - surrogateData(:, i)), 'number', i);
        legend{end + 1} = sprintf('%s %.4f', errorMetric, ...
          Error.compute(errorMetric, data(:, i), surrogateData(:, i)));
      end

      Plot.title('Absolute error at %.3f s', ...
        Istep * options.samplingInterval);
      Plot.label(sprintf('Parameters: %s, Variables: %s', ...
        String(Iparameter), String(Ivariable(Iparameter))), ...
        'log(Absolute error, C)');
      Plot.legend(legend{:});

      set(gca, 'YScale', 'log');

      Plot.figure(800, 400);

      for i = 1:options.processorCount
        Plot.line(parameterLine, data(:, i), 'number', i);
        Plot.line(parameterLine, surrogateData(:, i), ...
          'auxiliary', true, 'style', { 'Color', 'k' });
      end
    end

    Plot.title('Temperature variation at %.3f s', ...
      Istep * options.samplingInterval);
    Plot.label(sprintf('Paramters: %s, Variables: %s', ...
      String(Iparameter), String(Ivariable(Iparameter))), ...
      'Temperature, C');

    if ~Console.question('Sweep more? '), break; end
  end
end

function index = askInteger(name, maximum, index)
  if maximum == 1
    index = 1;
    return;
  end

  index = Console.request( ...
    'prompt', sprintf('Which %s (up to %d)? [%s] ', name, ...
    maximum, String(index)), 'default', index);

  if any(index < 1) || any(index > maximum), index = []; end
end
