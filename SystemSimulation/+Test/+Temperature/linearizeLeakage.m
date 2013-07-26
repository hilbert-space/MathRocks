function linearizeLeakage(varargin)
  setup;

  options = Configure.systemSimulation('processorCount', 2, varargin{:});
  options.leakageOptions.TRange = Utils.toKelvin([ 40, 400 ]);

  errorMetric = 'NRMSE';
  analysis = options.get('analysis', 'DynamicSteadyState');

  one = Temperature.Analytical.(analysis)(options);
  Tzero = Utils.toCelsius(one.compute( ...
    options.dynamicPower, options, 'disableLeakage', true));
  Tone = Utils.toCelsius(one.compute( ...
    options.dynamicPower, options));

  two = Temperature.Analytical.(analysis)(options, ...
    'linearizeLeakage', Options( ...
      'VRange', 45e-9 + 0.05 * 45e-9 * [ -1, 1 ], ...
      'TRange', Utils.toKelvin([ 60, 90 ])));
  Ttwo = Utils.toCelsius(two.compute(options.dynamicPower, options));

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

  Plot.title('Non-linear vs. Linear: %s %.4f', errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
