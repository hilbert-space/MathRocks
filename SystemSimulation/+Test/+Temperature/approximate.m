function approximate
  close all;
  setup;

  options = Configure.systemSimulation('processorCount', 32);

  fine = Temperature.Analytical.DynamicSteadyState(options);
  coarse = Temperature.Analytical.DynamicSteadyState(options, ...
    'coarseCircuit', false, 'modelReduction', 0.6);

  Tfine = Utils.toCelsius(fine.compute(options.dynamicPower, options));
  Tcoarse = Utils.toCelsius(coarse.compute(options.dynamicPower, options));

  time = options.timeLine;

  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, Tfine(i, :), 'Color', color);
    line(time, Tcoarse(i, :), 'Color', color, 'LineStyle', '--');
  end

  Plot.title('Fine (%d nodes) vs. Coarse (%d nodes): RMSE %.4f C', ...
    fine.nodeCount, coarse.nodeCount, Error.computeRMSE(Tfine, Tcoarse));
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
end
