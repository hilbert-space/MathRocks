function compute(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);

  method = options.get('method', 'Chaos');
  analysis = options.get('analysis', 'Transient');

  switch method
  case 'Chaos'
    options = Configure.polynomialChaos(options);
  case 'ASGC'
    options = Configure.ASGC(options);
  end

  surrogate = Temperature.(method).(analysis)(options);

  iterationCount = options.get('iterationCount', 10);

  fprintf('Method: %s\n', method);
  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ Texp, output ] = surrogate.compute(options.dynamicPower);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  Plot.temperatureVariation(Texp, output.Tvar, ...
    'time', options.timeLine, 'layout', 'one');
end
