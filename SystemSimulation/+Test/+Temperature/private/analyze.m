function analyze(method, analysis, iterationCount, varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  Pdyn = options.dynamicPower;

  temperature = Temperature.(method).(analysis)(options.temperatureOptions);

  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ T, output ] = temperature.compute(Pdyn, options);
  end
  time = toc(time) / iterationCount;
  fprintf('Average computational time: %.4f s\n', time);

  Plot.powerTemperature(Pdyn, output.P - Pdyn, ...
    T, temperature.samplingInterval);

  Ptot  = mean(output.P(:));
  Pdyn  = mean(Pdyn(:));
  Pleak = mean(output.P(:) - Pdyn(:));

  fprintf('Average total power:        %.2f W\n', Ptot);
  fprintf('Average dynamic power:      %.2f W\n', Pdyn);
  fprintf('Average leakage power:      %.2f W\n', Pleak);
  fprintf('Leakage to dynamic ratio:   %.2f\n', Pleak / Pdyn);
end
