function compute(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});

  method = options.get('method', 'Analytical');
  analysis = options.get('analysis', 'DynamicSteadyState');

  Pdyn = options.dynamicPower;

  temperature = Temperature.(method).(analysis)(options);

  time = tic;
  [ T, output ] = temperature.compute(Pdyn, options);
  time = toc(time);

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

  fprintf('Method:                     %s\n', method);
  fprintf('Analysis:                   %s\n', analysis);
  fprintf('Computational time:         %.2f s\n', time);
  fprintf('Average total power:        %.2f W\n', Ptot);
  fprintf('Average dynamic power:      %.2f W\n', Pdyn);
  fprintf('Average leakage power:      %.2f W\n', Pleak);
  fprintf('Leakage to dynamic ratio:   %.2f\n', Pleak / Pdyn);
end
