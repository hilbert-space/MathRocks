function benchmark(varargin)
  setup;

  options = Options( ...
    'samplingInterval', 1e-3, ...
    'temperatureOptions', Options( ...
      'method', 'Analytical', ...
      'analysis', 'DynamicSteadyState', ...
      'algorithm', 'blockCirculant', ... condensedEquation
      'leakage', [] ...
    ), ...
    varargin{:} ...
  );

  options = Configure.systemSimulation(options);
  options = Configure.deterministicAnalysis(options);

  P = options.dynamicPower;
  iterationCount = options.get('iterationCount', 1);

  temperature = Temperature(options.temperatureOptions);

  fprintf('%s: running %d iterations with %d steps each...\n', ...
    class(temperature), iterationCount, options.stepCount);
  time = tic;
  for i = 1:iterationCount
    T = temperature.compute(P);
  end
  time = toc(time);
  fprintf('%s: done in %.2f seconds (average is %.2f seconds).\n', ...
    class(temperature), time, time / iterationCount);

  Plot.figure(800, 700);

  T = T(:, :, 1);
  P = P(:, :, 1);

  subplot(2, 1, 1);
  Plot.power(P, [], 'timeLine', options.timeLine, 'figure', false);

  subplot(2, 1, 2);
  Plot.temperature(T, 'timeLine', options.timeLine, 'figure', false);
end
