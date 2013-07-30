function compare(options, secondOptions)
  close all;
  setup;

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);
  options = Configure.polynomialChaos(options);

  oneMethod = 'MonteCarlo';
  twoMethod = options.get('method', 'Chaos');

  analysis = options.get('analysis', 'Transient');

  fprintf('Method 1: %s\n', oneMethod);
  fprintf('Method 2: %s\n', twoMethod);
  fprintf('Analysis: %s\n', analysis);

  oneSampleCount = 1e4;
  twoSampleCount = 1e4;

  timeSlice = options.stepCount * options.samplingInterval / 2;
  k = floor(timeSlice / options.samplingInterval);

  one = Temperature.(oneMethod).(analysis)(options);
  two = Temperature.(twoMethod).(analysis)(options, secondOptions);

  [ oneTexp, oneOutput ] = one.compute(options.dynamicPower, ...
    'sampleCount', oneSampleCount, 'verbose', true, options);

  [ twoTexp, twoOutput ] = two.compute(options.dynamicPower, ...
    'sampleCount', twoSampleCount, 'verbose', true, secondOptions);

  if ~isfield(twoOutput, 'Tdata')
    twoOutput.Tdata = two.sample(twoOutput, twoSampleCount);
  end

  %
  % Comparison of expectations, variances, and PDFs
  %
  if Console.question('Compare expectations, variances, and PDFs? ')
    Plot.temperatureVariation({ oneTexp, twoTexp }, ...
       { oneOutput.Tvar, twoOutput.Tvar }, ...
      'time', options.timeLine, 'names', { oneMethod, twoMethod });

    Data.compare(Utils.toCelsius(oneOutput.Tdata(:, :, k)), ...
      Utils.toCelsius(twoOutput.Tdata(:, :, k)), ...
      'method', 'smooth', 'range', 'unbounded', ...
      'layout', 'one', 'draw', true, ...
      'names', { oneMethod, twoMethod });

    Data.compare( ...
      Utils.toCelsius(oneOutput.Tdata), ...
      Utils.toCelsius(twoOutput.Tdata), ...
      'method', 'histogram', 'range', 'unbounded', ...
      'layout', 'separate', 'draw', true, ...
      'names', { oneMethod, twoMethod });
  end

  %
  % Sweeping the random variables
  %
  index = uint8(1);
  while Console.question('Sweep random variables? ')
    switch options.processModel
    case 'Normal'
      rvs = -7:0.2:7;
    otherwise
      assert(false);
    end

    index = Console.request( ...
     'prompt', sprintf('Which random variables? [%s] ', ...
      Utils.toString(index)), 'type', 'uint8', 'default', index);

    if any(index > one.process.dimensionCount), continue; end

    RVs = zeros(length(rvs), one.process.dimensionCount);
    for i = index
      RVs(:, i) = rvs;
    end

    oneTdata = one.evaluate(oneOutput, RVs);
    twoTdata = two.evaluate(twoOutput, RVs);

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
