function assessVariations(varargin)
  setup;

  sampleCount = 1e5;
  processorCountSet = [ 2 4 8 16 32 ];

  for processorCount = processorCountSet
    options = configure(varargin{:}, 'processorCount', processorCount);

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
  end
end
