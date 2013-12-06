function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);

  Pdyn = options.dynamicPower;
  sampleCount = options.get('sampleCount', 100);
  iterationCount = options.get('iterationCount', 10);

  parameters = options.processParameters;
  names = fieldnames(parameters);
  parameterCount = length(parameters);

  assignments = struct;
  for i = 1:parameterCount
    assignments.(names{i}) = parameters.(names{i}).nominal * ...
      ones(sampleCount, options.processorCount);
  end

  temperature = Temperature(options.temperatureOptions);

  fprintf('%s: running %d iterations with %d samples each...\n', ...
    class(temperature), iterationCount, sampleCount);
  time = tic;
  for i = 1:iterationCount
    [ T, output ] = temperature.compute(Pdyn, assignments);
  end
  time = toc(time);
  fprintf('%s: done in %.2f seconds (average is %.2f seconds).\n', ...
    class(temperature), time, time / iterationCount);

  if isfield(output, 'P') && ~isempty(output.P)
    P = output.P;
  else
    P = Pdyn;
  end

  T = T(:, :, 1);
  P = P(:, :, 1);

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
