function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);
  options = Configure.surrogate(options);

  surrogate = options.fetch('surrogate', 'Chaos');
  analysis = options.fetch('analysis', 'Transient');
  iterationCount = options.fetch('iterationCount', 1);

  fprintf('Surrogate: %s\n', surrogate);
  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);

  surrogate = instantiate(surrogate, analysis, options);

  time = tic;
  for i = 1:iterationCount
    surrogateOutput = surrogate.compute(options.dynamicPower);
  end
  fprintf('Average construction time: %.2f s\n', toc(time) / iterationCount);

  time = tic;
  for i = 1:iterationCount
    surrogateStats = surrogate.analyze(surrogateOutput);
  end
  fprintf('Average analysis time: %.2f s\n', toc(time) / iterationCount);

  display(surrogate, surrogateOutput);
  plot(surrogate, surrogateOutput);

  Plot.figure(800, 800);
  subplot(2, 1, 1);
  plot(options.power, options.dynamicPower, 'figure', false);
  subplot(2, 1, 2);
  Plot.temperatureVariation(surrogateStats.expectation, ...
     surrogateStats.variance, 'time', options.timeLine, ...
    'figure', false, 'layout', 'one');
end
