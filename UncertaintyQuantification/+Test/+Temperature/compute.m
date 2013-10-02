function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);
  options = Configure.surrogate(options);

  surrogate = options.fetch('surrogate', 'Chaos');
  analysis = options.fetch('analysis', 'Transient');
  iterationCount = options.fetch('iterationCount', 10);

  fprintf('Surrogate: %s\n', surrogate);
  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);

  surrogate = Temperature.(surrogate).(analysis)(options);

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
