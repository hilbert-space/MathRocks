function approximate(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});

  errorMetric = 'RMSE';
  analysis = options.get('analysis', 'DynamicSteadyState');

  fine = Temperature.Analytical.(analysis)(options);
  Tfine = Utils.toCelsius(fine.compute(options.dynamicPower, options));

  minimalError = 0.1;
  reductionLimit = 0.4:0.05:1;

  fprintf('%15s%15s%15s\n', 'Reduction', 'Nodes', errorMetric);
  for limit = reductionLimit
    coarse = Temperature.Analytical.(analysis)(options, ...
      'reductionThreshold', 0, 'reductionLimit', limit);
    Tcoarse = Utils.toCelsius(coarse.compute(options.dynamicPower, options));

    error = Error.compute(errorMetric, Tfine, Tcoarse);
    fprintf('%15.2f%15s%15.4f\n', limit, ...
      sprintf('%3d /%3d', coarse.nodeCount, fine.nodeCount), error);

    if error < minimalError, break; end
  end

  time = options.timeLine;

  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, Tfine(i, :), 'Color', color);
    line(time, Tcoarse(i, :), 'Color', color, 'LineStyle', '--');
  end

  Plot.title('Fine (%d nodes) vs. Coarse (%d nodes): %s %.4f', ...
    fine.nodeCount, coarse.nodeCount, errorMetric, error);
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
