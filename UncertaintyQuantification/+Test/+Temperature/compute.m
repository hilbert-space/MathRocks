function compute(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);
  options = Configure.polynomialChaos(options);

  analysis = options.get('analysis', 'Transient');

  surrogate = Temperature.Chaos.(analysis)(options);

  iterationCount = options.get('iterationCount', 10);

  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ Texp, output ] = surrogate.compute(options.dynamicPower, options);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  Plot.figure(800, 400);
  subplot(2, 1, 1);
  plot(options.power, options.dynamicPower, 'figure', false, 'markEach', 18);
  subplot(2, 1, 2);
  Plot.temperatureVariation(Texp, output.Tvar, 'time', options.timeLine, ...
    'figure', false, 'markEach', 18, 'layout', 'one');
end
