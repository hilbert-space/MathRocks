function analyze(method, analysis, varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.processVariation(options);

  switch method
  case 'Chaos'
    options = Configure.polynomialChaos(options);
  case 'ASGC'
    options = Configure.ASGC(options);
  end

  surrogate = Temperature.(method).(analysis)(options);

  iterationCount = options.get('iterationCount', 10);

  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ Texp, output ] = surrogate.compute(options.dynamicPower);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  time = options.samplingInterval * (1:options.stepCount);

  Plot.temperatureVariation(time, Texp, output.Tvar, 'layout', 'one');
end
