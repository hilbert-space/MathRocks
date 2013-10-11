function compare(options, secondOptions)
  if nargin < 2, secondOptions = []; end

  close all;
  setup;

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);
  options = Configure.surrogate(options);

  oneMethod = 'MonteCarlo';
  twoMethod = options.fetch('surrogate', 'Chaos');

  analysis = options.fetch('analysis', 'Transient');

  fprintf('Analysis: %s\n', analysis);

  sampleCount = 1e4;

  timeSlice = options.stepCount * options.samplingInterval / 2;
  k = floor(timeSlice / options.samplingInterval);

  one = Temperature.(oneMethod).(analysis)( ...
    options, 'sampleCount', sampleCount);
  two = Temperature.(twoMethod).(analysis)( ...
    options, secondOptions, 'sampleCount', sampleCount);

  [ oneTexp, oneOutput ] = one.compute(options.dynamicPower);

  time = tic;
  fprintf('%s: construction...\n', twoMethod);
  [ twoTexp, twoOutput ] = two.compute(options.dynamicPower);
  fprintf('%s: done in %.2f seconds.\n', twoMethod, toc(time));

  stats = two.computeStatistics(twoOutput);
  display(stats, sprintf('Statistics of %s', twoMethod));

  if ~isfield(twoOutput, 'Tdata') || isempty(twoOutput.Tdata)
    time = tic;
    fprintf('%s: collecting %d samples...\n', twoMethod, sampleCount);
    twoOutput.Tdata = two.sample(twoOutput, sampleCount);
    fprintf('%s: done in %.2f seconds.\n', twoMethod, toc(time));
  end

  if ~isfield(twoOutput, 'Tvar') || isempty(twoOutput.Tvar)
    twoOutput.Tvar = squeeze(var(twoOutput.Tdata, [], 1));
  end

  %
  % Comparison of expectations, variances, and PDFs
  %
  if Console.question('Compare expectations, variances, and PDFs? ')
    Plot.temperatureVariation({ oneTexp, twoTexp }, ...
       { oneOutput.Tvar, twoOutput.Tvar }, ...
      'time', options.timeLine, 'names', { oneMethod, twoMethod });

    Statistic.compare(Utils.toCelsius(oneOutput.Tdata(:, :, k)), ...
      Utils.toCelsius(twoOutput.Tdata(:, :, k)), ...
      'method', 'smooth', 'range', 'unbounded', ...
      'layout', 'one', 'draw', true, ...
      'names', { oneMethod, twoMethod });

    Statistic.compare( ...
      Utils.toCelsius(oneOutput.Tdata), ...
      Utils.toCelsius(twoOutput.Tdata), ...
      'method', 'histogram', 'range', 'unbounded', ...
      'layout', 'separate', 'draw', true, ...
      'names', { oneMethod, twoMethod });
  end

  if one.process.dimensions ~= two.process.dimensions, return; end

  parameters = options.processOptions.parameters;
  dimensions = one.process.dimensions;
  parameterCount = length(dimensions);
  names = fieldnames(parameters);

  nominals = cell(1, parameterCount);
  sweeps = cell(1, parameterCount);
  for i = 1:parameterCount
    switch parameters.get(i).model
    case 'Gaussian'
      sweeps{i} = -7:0.2:7;
    otherwise
      assert(false);
    end
    nominals{i} = zeros(length(sweeps{i}), dimensions{i});
  end

  %
  % Sweeping the random variables
  %
  Iparam = 1;
  Irv = uint8(1);
  while Console.question('Sweep random variables? ')
    if length(names) > 1
      name = Console.request( ...
       'prompt', sprintf('Which parameter? [%s] ', names{Iparam}), ...
       'type', 'char', 'default', names{Iparam});

      found = false;
      for i = 1:length(names)
        if strcmp(names{i}, name)
          found = true;
          break;
        end
      end

      if ~found
        Iparam = 1;
        continue;
      end

      Iparam = i;
    end

    Irv = Console.request( ...
     'prompt', sprintf('Which random variable? [%s] ', ...
       String(Irv)), 'type', 'uint8', 'default', Irv);

    dimensionCount = dimensions(Iparam);

    if any(Irv > dimensionCount)
      Irv = uint8(1);
      continue;
    end

    parameters = nominals;
    for i = Irv
      parameters{Iparam}(:, i) = sweeps{Iparam};
    end

    oneTdata = one.evaluate(oneOutput, parameters);
    twoTdata = two.evaluate(twoOutput, parameters);

    oneTdata = Utils.toCelsius(oneTdata(:, :, k));
    twoTdata = Utils.toCelsius(twoTdata(:, :, k));

    figure;
    for i = 1:options.processorCount
      color = Color.pick(i);
      line(rvs, oneTdata(:, i), 'Color', color, 'Marker', 'o');
      line(rvs, twoTdata(:, i), 'Color', color, 'Marker', 'x');
    end

    Plot.title('Sweep at %.3f s', timeSlice);
    Plot.label('Variable', 'Temperature, C');
  end
end
