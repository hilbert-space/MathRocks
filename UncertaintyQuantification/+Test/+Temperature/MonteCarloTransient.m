function MonteCarloTransient
  close all;
  setup;

  chaosSampleCount = 1e5;
  carloSampleCount = 1e4;

  options = Test.configure;

  time = options.samplingInterval * (0:(options.stepCount - 1));

  timeSlice = options.stepCount * options.samplingInterval / 2;
  k = floor(timeSlice / options.samplingInterval);

  %
  % One polynomial chaos.
  %
  chaos = Temperature.Chaos.Transient(options);

  %
  % Monte Carlo simulations.
  %
  mc = Temperature.MonteCarlo.Transient(options);

  tic;
  [ Texp1, output1 ] = chaos.compute(options.dynamicPower);
  fprintf('Polynomial chaos: construction time %.2f s.\n', toc);

  %
  % Comparison of expectations, variances, and PDFs.
  %
  if Terminal.question('Compare expectations, variances, and PDFs? ')
    tic;
    Tdata1 = chaos.sample(output1.coefficients, chaosSampleCount);
    fprintf('Polynomial chaos: sampling time %.2f s (%d samples).\n', ...
      toc, chaosSampleCount);

    [ Texp2, output2 ] = mc.compute(options.dynamicPower, ...
      'sampleCount', carloSampleCount, 'verbose', true);

    labels = { 'PC', 'MC' };

    Utils.drawTemperature(time, ...
      { Utils.toCelsius(Texp1), Utils.toCelsius(Texp2) }, ...
      { output1.Tvar, output2.Tvar }, 'labels', labels);

    Tdata1 = Utils.toCelsius(Tdata1);
    Tdata2 = Utils.toCelsius(output2.Tdata);

    Data.compare(Tdata1, Tdata2, ...
      'method', 'histogram', 'range', 'unbounded', ...
      'layout', 'separate', 'draw', true, ...
      'labels', labels);
  end

  %
  % Sweeping the random parameters.
  %
  rvs = -7:0.2:7;
  index = uint8(1);
  while Terminal.question('Sweep random variables? ')
    index = Terminal.request( ...
     'prompt', sprintf('Which random variables? [%s] ', Utils.toString(index)), ...
     'type', 'uint8', 'default', index);

    if any(index > chaos.process.dimensionCount), continue; end

    RVs = zeros(length(rvs), chaos.process.dimensionCount);
    for i = index
      RVs(:, i) = rvs;
    end

    Tdata1 = chaos.evaluate(output1.coefficients, RVs);
    Tdata2 = mc.evaluate(options.dynamicPower, RVs);

    Tdata1 = Utils.toCelsius(Tdata1(:, :, k));
    Tdata2 = Utils.toCelsius(Tdata2(:, :, k));

    figure;
    for i = 1:options.processorCount
      color = Color.pick(i);
      line(rvs, Tdata1(:, i), 'Color', color, 'Marker', 'o');
      line(rvs, Tdata2(:, i), 'Color', color, 'Marker', 'x');
    end
    Plot.title('Sweep at %.3f s', timeSlice);
    Plot.label('Random parameter', 'Temperature, C');
  end
end
