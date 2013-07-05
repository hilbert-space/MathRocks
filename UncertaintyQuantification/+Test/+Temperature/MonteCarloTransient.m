function MonteCarloTransient(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);
  options = Configure.polynomialChaos(options);

  chaosSampleCount = 1e5;
  carloSampleCount = 1e4;

  time = options.samplingInterval * (0:(options.stepCount - 1));

  timeSlice = options.stepCount * options.samplingInterval / 2;
  k = floor(timeSlice / options.samplingInterval);

  %
  % One polynomial chaos.
  %
  pc = Temperature.Chaos.Transient(options);

  %
  % Monte Carlo simulations.
  %
  mc = Temperature.MonteCarlo.Transient(options);

  tic;
  [ pcTexp, pcOutput ] = pc.compute(options.dynamicPower);
  fprintf('Polynomial chaos: construction time %.2f s.\n', toc);

  %
  % Comparison of expectations, variances, and PDFs.
  %
  if Terminal.question('Compare expectations, variances, and PDFs? ')
    tic;
    pcOutput.Tdata = pc.sample(pcOutput, chaosSampleCount);
    fprintf('Polynomial chaos: sampling time %.2f s (%d samples).\n', ...
      toc, chaosSampleCount);

    [ mcTexp, mcOutput ] = mc.compute(options.dynamicPower, ...
      'sampleCount', carloSampleCount, 'verbose', true);

    Utils.plotTemperatureVariation(time, ...
      { pcTexp, mcTexp }, { pcOutput.Tvar, mcOutput.Tvar }, ...
      'labels', { 'PC', 'MC' });

    pcTdata = Utils.toCelsius(pcOutput.Tdata);
    mcTdata = Utils.toCelsius(mcOutput.Tdata);

    Data.compare(pcTdata, mcTdata, ...
      'method', 'histogram', 'range', 'unbounded', ...
      'layout', 'separate', 'draw', true, ...
      'labels', { 'PC', 'MC' });
  end

  %
  % Sweeping the random parameters.
  %
  switch options.processModel
  case 'Normal'
    rvs = -7:0.2:7;
  otherwise
    assert(false);
  end

  index = uint8(1);
  while Terminal.question('Sweep random variables? ')
    index = Terminal.request( ...
     'prompt', sprintf('Which random variables? [%s] ', Utils.toString(index)), ...
     'type', 'uint8', 'default', index);

    if any(index > pc.process.dimensionCount), continue; end

    RVs = zeros(length(rvs), pc.process.dimensionCount);
    for i = index
      RVs(:, i) = rvs;
    end

    pcTdata = pc.evaluate(pcOutput, RVs);
    mcTdata = mc.evaluate(options.dynamicPower, RVs);

    pcTdata = Utils.toCelsius(pcTdata(:, :, k));
    mcTdata = Utils.toCelsius(mcTdata(:, :, k));

    figure;
    for i = 1:options.processorCount
      color = Color.pick(i);
      line(rvs, pcTdata(:, i), 'Color', color, 'Marker', 'o');
      line(rvs, mcTdata(:, i), 'Color', color, 'Marker', 'x');
    end
    Plot.title('Sweep at %.3f s', timeSlice);
    Plot.label('Random parameter', 'Temperature, C');
  end
end
