function assess(one, two, varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);

  errorMetric = 'RMSE';

  one = Temperature(options.temperatureOptions, one);
  T0 = Utils.toCelsius(one.computeWithoutLeakage(options.dynamicPower));
  T1 = Utils.toCelsius(one.compute(options.dynamicPower));

  two = Temperature(options.temperatureOptions, two);
  T2 = Utils.toCelsius(two.compute(options.dynamicPower));

  error = Error.compute(errorMetric, T1, T2);

  time = options.timeLine;

  Plot.figure(1200, 400);
  for i = 1:options.processorCount
    Plot.line(time, T0(i, :), 'style', { 'Color', 0.8 * [1, 1, 1] });
    Plot.line(time, T1(i, :), 'number', i);
    Plot.line(time, T2(i, :), 'number', i, 'auxiliary', true);
  end

  Plot.title('%s: %s %.4f', class(one), errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
