function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);

  Pdyn = options.dynamicPower;
  iterationCount = options.fetch('iterationCount', 10);

  temperature = Temperature(options.temperatureOptions);

  fprintf('%s: running %d iterations...\n', ...
    class(temperature), iterationCount);
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

  Plot.figure(800, 700);
  subplot(2, 1, 1);
  Plot.power(Pdyn, P - Pdyn, 'timeLine', options.timeLine, 'figure', false);
  subplot(2, 1, 2);
  Plot.temperature(T, 'timeLine', options.timeLine, 'figure', false);

  Ptotal = mean(P(:));
  Pdyn = mean(Pdyn(:));
  Pleak = mean(P(:) - Pdyn(:));

  fprintf('Total power: %.2f W\n', Ptotal);
  fprintf('Dynamic power: %.2f W\n', Pdyn);
  fprintf('Leakage power: %.2f W\n', Pleak);
  fprintf('Leakage to dynamic ratio: %.2f\n', Pleak / Pdyn);
end
