function assessVariations(varargin)
  setup;

  sampleCount = 1e5;
  processorCountSet = [2 4 8 16 32];

  for processorCount = processorCountSet
    options = Configure.systemSimulation(varargin{:}, ...
      'processorCount', processorCount);
    options = Configure.deterministicAnalysis(options);
    options = Configure.stochasticAnalysis(options);

    parameters = options.processOptions.parameters;
    parameterCount = length(parameters);
    parameterNames = fieldnames(parameters);

    process = ProcessVariation(options.processOptions);

    fprintf('Processors: %d, variables: %d\n', ...
      processorCount, sum(process.dimensions));
    fprintf('%10s', 'Processor');
    for i = 1:parameterCount
      fprintf('%20s', parameterNames{i});
    end
    fprintf('\n');

    samples = process.sample(sampleCount);

    expectations = zeros(processorCount, parameterCount);
    variances = zeros(processorCount, parameterCount);

    for i = 1:parameterCount
      expectations(:, i) = mean(samples{i}, 1) / ...
        parameters.(parameterNames{i}).expectation;
      variances(:, i) = var(samples{i}, 0, 1) / ...
        parameters.(parameterNames{i}).variance;
    end

    for i = 1:processorCount
      fprintf('%10d', i);
      for j = 1:parameterCount
        fprintf('%11.4f / %6.4f', ...
          expectations(i, j), variances(i, j));
      end
      fprintf('\n');
    end

    fprintf('\n');

    if ~options.get('draw', false), continue; end

    Plot.figure(1000, 400);
    Plot.name('%d processors', processorCount);

    for i = 1:parameterCount
      name = parameterNames{i};
      parameter = parameters.(name);

      subplot(1, parameterCount, i);
      Plot.label(name, 'Probability density');

      x = linspace(parameter.range(1), parameter.range(2), 50);
      y = normpdf(x, parameter.nominal, sqrt(parameter.variance));
      Plot.line(x, y, 'style', { 'Color', 'k' });

      for j = 1:processorCount
        Plot.distribution(samples{i}(:, j), 'layout', 'one', 'figure', false);
      end
    end
  end
end
