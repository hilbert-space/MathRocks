function linearizeLeakage(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});

  errorMetric = 'RMSE';
  analysis = options.get('analysis', 'DynamicSteadyState');

  one = Temperature.Analytical.(analysis)(options);
  Tone = Utils.toCelsius(one.compute(options.dynamicPower, options));

  two = Temperature.Analytical.(analysis)(options, ...
    'linearizeLeakage', Options('TRange', Utils.toKelvin([ 45, 120 ])));
  Ttwo = Utils.toCelsius(two.compute(options.dynamicPower, options));

  error = Error.compute(errorMetric, Tone, Ttwo);

  time = options.timeLine;

  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, Tone(i, :), 'Color', color);
    line(time, Ttwo(i, :), 'Color', color, 'LineStyle', '--');
  end

  Plot.title('Non-linear vs. Linear: %s %.4f', errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
