function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);
  options = Configure.polynomialChaos(options);

  analysis = options.fetch('analysis', 'Transient');
  iterationCount = options.fetch('iterationCount', 10);

  surrogate = Temperature.Chaos.(analysis)(options);

  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ Texp, output ] = surrogate.compute(options.dynamicPower);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  Plot.figure(800, 400);
  subplot(2, 1, 1);
  plot(options.power, options.dynamicPower, 'figure', false);
  subplot(2, 1, 2);
  Plot.temperatureVariation(Texp, output.Tvar, 'time', options.timeLine, ...
    'figure', false, 'layout', 'one');
end
