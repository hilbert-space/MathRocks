function coarse
  close all;
  setup;

  options = Configure.systemSimulation('processorCount', 1);

  fine = Temperature.Analytical.DynamicSteadyState(options, ...
    'coarseHotSpot', false);
  coarse = Temperature.Analytical.DynamicSteadyState(options, ...
    'coarseHotSpot', true);

  Tfine = Utils.toCelsius(fine.compute(options.dynamicPower, options));
  Tcoarse = Utils.toCelsius(coarse.compute(options.dynamicPower, options));

  time = options.timeLine;

  Plot.title('Fine (%d nodes) vs. Coarse (%d nodes)', ...
    fine.nodeCount, coarse.nodeCount);
  Plot.label('Time, s', 'Temperature, C');
  for i = 1:options.processorCount
    line(time, abs(Tfine(i, :) - Tcoarse(i, :)), 'Color', Color.pick(i));
  end
  Plot.limit(time);
end
