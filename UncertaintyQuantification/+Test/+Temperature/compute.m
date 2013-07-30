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

  Plot.temperatureVariation(Texp, output.Tvar, ...
    'time', options.timeLine, 'layout', 'one');
end
