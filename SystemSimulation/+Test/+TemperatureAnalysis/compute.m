function compute(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});

  method = options.fetch('method', 'Analytical');
  analysis = options.fetch('analysis', 'Transient');
  iterationCount = options.fetch('iterationCount', 10);

  Pdyn = options.dynamicPower;

  temperature = TemperatureAnalysis.(method).(analysis)(options);

  fprintf('Method: %s\n', method);
  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ T, output ] = temperature.compute(Pdyn);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  if isfield(output, 'P') && ~isempty(output.P)
    P = output.P;
  else
    P = Pdyn;
  end

  Plot.powerTemperature(Pdyn, P - Pdyn, T, ...
    'time', options.timeLine);

  Ptot  = mean(P(:));
  Pdyn  = mean(Pdyn(:));
  Pleak = mean(P(:) - Pdyn(:));

  fprintf('Total power: %.2f W\n', Ptot);
  fprintf('Dynamic power: %.2f W\n', Pdyn);
  fprintf('Leakage power: %.2f W\n', Pleak);
  fprintf('Leakage to dynamic ratio: %.2f\n', Pleak / Pdyn);
end
