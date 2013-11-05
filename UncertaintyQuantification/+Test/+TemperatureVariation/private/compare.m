function compare(options, secondOptions)
  if nargin < 2, secondOptions = []; end

  close all;
  setup;

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);
  options = Configure.temperatureVariation(options);

  oneMethod = 'MonteCarlo';
  twoMethod = options.fetch('surrogate', 'Chaos');

  analysis = options.fetch('analysis', 'Transient');

  fprintf('Analysis: %s\n', analysis);

  sampleCount = 1e4;

  timeSlice = options.stepCount * options.samplingInterval / 2;
  k = floor(timeSlice / options.samplingInterval);

  one = instantiate(oneMethod, analysis, ...
    options, 'sampleCount', sampleCount);
  two = instantiate(twoMethod, analysis, ...
    options, secondOptions, 'sampleCount', sampleCount);

  oneOutput = one.compute(options.dynamicPower);

  time = tic;
  fprintf('%s: construction...\n', twoMethod);
  twoOutput = two.compute(options.dynamicPower);
  fprintf('%s: done in %.2f seconds.\n', twoMethod, toc(time));

  display(two, twoOutput);

  time = tic;
  fprintf('%s: analysis...\n', oneMethod);
  oneStats = one.analyze(oneOutput);
  fprintf('%s: done in %.2f seconds.\n', oneMethod, toc(time));

  time = tic;
  fprintf('%s: analysis...\n', twoMethod);
  twoStats = two.analyze(twoOutput);
  fprintf('%s: done in %.2f seconds.\n', twoMethod, toc(time));

  if ~isfield(twoOutput, 'data') || isempty(twoOutput.data)
    time = tic;
    fprintf('%s: collecting %d samples...\n', twoMethod, sampleCount);
    twoOutput.data = two.sample(twoOutput, sampleCount);
    fprintf('%s: done in %.2f seconds.\n', twoMethod, toc(time));
  end

  if ~isfield(twoStats, 'variance') || ...
    isempty(twoStats.variance) || ...
    any(isnan(twoStats.variance(:)))

    twoStats.variance = squeeze(var(twoOutput.data, [], 1));
  end

  %
  % Comparison of expectations, variances, and PDFs
  %
  Plot.temperatureVariation( ...
    { oneStats.expectation, twoStats.expectation }, ...
    { oneStats.variance, twoStats.variance }, ...
    'time', options.timeLine, 'names', { oneMethod, twoMethod });

  Statistic.compare( ...
    Utils.toCelsius(oneOutput.data(:, :, k)), ...
    Utils.toCelsius(twoOutput.data(:, :, k)), ...
    'method', 'smooth', 'range', 'unbounded', ...
    'layout', 'one', 'draw', true, ...
    'names', { oneMethod, twoMethod });

  Statistic.compare( ...
    Utils.toCelsius(oneOutput.data), ...
    Utils.toCelsius(twoOutput.data), ...
    'method', 'histogram', 'range', 'unbounded', ...
    'layout', 'separate', 'draw', true, ...
    'names', { oneMethod, twoMethod });
end
