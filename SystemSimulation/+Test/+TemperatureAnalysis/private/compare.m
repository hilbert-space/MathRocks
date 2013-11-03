function compare(options, secondOptions)
  close all;
  setup;

  options = Configure.systemSimulation(options);

  errorMetric = 'RMSE';
  analysis = options.get('analysis', 'Transient');

  one = TemperatureAnalysis.Analytical.(analysis)(options);
  T0 = Utils.toCelsius(one.computeWithoutLeakage(options.dynamicPower));
  T1 = Utils.toCelsius(one.compute(options.dynamicPower));

  two = TemperatureAnalysis.Analytical.(analysis)(options, secondOptions);
  T2 = Utils.toCelsius(two.compute(options.dynamicPower));

  error = Error.compute(errorMetric, T1, T2);

  fprintf('Analysis: %s\n', analysis);
  fprintf('%s: %.4f\n', errorMetric, error);

  time = options.timeLine;

  Plot.figure(1200, 400);
  for i = 1:options.processorCount
    Plot.line(time, T0(i, :), 'style', { 'Color', 0.8 * [ 1, 1, 1 ] });
    Plot.line(time, T1(i, :), 'number', i);
    Plot.line(time, T2(i, :), 'number', i, 'auxiliary', true);
  end

  Plot.title('%s %.4f', errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
