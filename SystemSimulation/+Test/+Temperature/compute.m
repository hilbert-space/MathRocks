function compute(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});

  method = options.get('method', 'Analytical');
  analysis = options.get('analysis', 'Transient');

  Pdyn = options.dynamicPower;

  temperature = Temperature.(method).(analysis)(options);

  iterationCount = options.get('iterationCount', 10);

  fprintf('Method: %s\n', method);
  fprintf('Analysis: %s\n', analysis);
  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ T, output ] = temperature.compute(Pdyn, options);
  end
  fprintf('Average computational time: %.2f s\n', toc(time) / iterationCount);

  if isfield(output, 'P')
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
