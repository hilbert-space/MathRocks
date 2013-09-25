function compare(options, secondOptions)
  close all;
  setup;

  options = Configure.systemSimulation(options);

  errorMetric = 'NRMSE';
  analysis = options.get('analysis', 'Transient');

  one = Temperature.Analytical.(analysis)(options);
  T0 = Utils.toCelsius(one.computeWithoutLeakage(options.dynamicPower));
  T1 = Utils.toCelsius(one.compute(options.dynamicPower));

  two = Temperature.Analytical.(analysis)(options, secondOptions);
  T2 = Utils.toCelsius(two.compute(options.dynamicPower));

  error = Error.compute(errorMetric, T1, T2);

  fprintf('Analysis: %s\n', analysis);
  fprintf('%s: %.4f\n', errorMetric, error);

  time = options.timeLine;

  Plot.figure(1200, 400);
  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, T0(i, :), 'Color', 0.8 * [ 1, 1, 1 ]);
    line(time, T1(i, :), 'Color', color);
    line(time, T2(i, :), 'Color', color, 'LineStyle', '--');
  end

  Plot.title('%s %.4f', errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
