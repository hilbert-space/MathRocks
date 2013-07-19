function coarse
  setup;

  options = Configure.systemSimulation('processorCount', 2);

  fine = Temperature.Analytical.Transient(options, ...
    'coarseHotSpot', false);
  coarse = Temperature.Analytical.Transient(options, ...
    'coarseHotSpot', true);

  Tfine = Utils.toCelsius(fine.compute(options.dynamicPower, options));
  Tcoarse = Utils.toCelsius(coarse.compute(options.dynamicPower, options));

  time = options.timeLine;

  Plot.title('Fine vs Coarse Temperature Analysis');
  Plot.label('Time, s', 'Temperature, C');
  for i = 1:options.processorCount
    color = Color.pick(i);
    line(time, Tfine(i, :), 'Color', color);
    line(time, Tcoarse(i, :), 'Color', color, 'LineStyle', '--');
  end
  Plot.limit(time);
end
