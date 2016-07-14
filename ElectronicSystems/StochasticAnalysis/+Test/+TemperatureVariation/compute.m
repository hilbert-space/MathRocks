function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);
  options = Configure.stochasticAnalysis(options);

  [~, stats] = construct(options);

  Plot.figure(800, 800);

  subplot(2, 1, 1);
  plot(options.power, options.dynamicPower, 'figure', false);

  subplot(2, 1, 2);
  Plot.temperatureVariation(stats.expectation, stats.variance, ...
    'time', options.timeLine, 'figure', false, 'layout', 'one');
end
