function compare(options, secondOptions)
  close all;
  setup;

  options = Configure.systemSimulation(options);

  errorMetric = 'NRMSE';
  analysis = options.get('analysis', 'Transient');

  one = Temperature.Analytical.(analysis)(options);
  Tzero = Utils.toCelsius(one.compute( ...
    options.dynamicPower, options, 'leakage', []));
  Tone = Utils.toCelsius(one.compute( ...
    options.dynamicPower, options));

  two = Temperature.Analytical.(analysis)(options, secondOptions);
  Ttwo = Utils.toCelsius(two.compute( ...
    options.dynamicPower, options, secondOptions));

  error = Error.compute(errorMetric, Tone, Ttwo);

  fprintf('Analysis: %s\n', analysis);
  fprintf('%s: %.4f\n', errorMetric, error);

  time = options.timeLine;

  Plot.figure(1200, 400);
  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, Tzero(i, :), 'Color', 0.8 * [ 1, 1, 1 ]);
    line(time, Tone(i, :), 'Color', color);
    line(time, Ttwo(i, :), 'Color', color, 'LineStyle', '--');
  end

  Plot.title('%s %.4f', errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
