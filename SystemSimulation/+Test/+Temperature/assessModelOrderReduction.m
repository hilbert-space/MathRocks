function assessModelOrderReduction(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});

  errorMetric = 'RMSE';
  analysis = options.get('analysis', 'Transient');

  fprintf('Analysis: %s\n', analysis);

  one = Temperature.Analytical.(analysis)(options);
  Tone = Utils.toCelsius(one.compute(options.dynamicPower, options));

  minimalError = 0.1;
  reductionLimit = 0.4:0.05:1;

  fprintf('%15s%15s%15s\n', 'Reduction', 'Nodes', errorMetric);
  for limit = reductionLimit
    two = Temperature.Analytical.(analysis)(options, ...
      'reduceModelOrder', Options('threshold', 0, 'limit', limit));
    Ttwo = Utils.toCelsius(two.compute(options.dynamicPower, options));

    error = Error.compute(errorMetric, Tone, Ttwo);
    fprintf('%15.2f%15s%15.4f\n', limit, ...
      sprintf('%3d /%3d', two.nodeCount, one.nodeCount), error);

    if error < minimalError, break; end
  end

  time = options.timeLine;

  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, Tone(i, :), 'Color', color);
    line(time, Ttwo(i, :), 'Color', color, 'LineStyle', '--');
  end

  Plot.title('Fine (%d nodes) vs. Coarse (%d nodes): %s %.4f', ...
    one.nodeCount, two.nodeCount, errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
