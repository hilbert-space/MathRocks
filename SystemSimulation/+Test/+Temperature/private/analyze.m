function analyze(method, analysis, iterationCount)
  setup;

  %
  % Platform and application
  %
  [ platform, application ] = Utils.parseTGFF( ...
    File.join('+Test', 'Assets', '004_080.tgff'));
  schedule = Schedule.Dense(platform, application);

  die = Die('floorplan', File.join('+Test', 'Assets', '004.flp'));
  plot(die);

  %
  % Dynamic power
  %
  power = DynamicPower(1e-3);
  Pdyn = power.compute(schedule);

  %
  % Leakage model
  %
  leakage = LeakagePower.LinearInterpolation('dynamicPower', Pdyn, ...
    'filename', File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_08.leak'));

  temperature = Temperature.(method).(analysis)('die', die, ...
    'config', File.join('+Test', 'Assets', 'hotspot.config'), ...
    'line', 'sampling_intvl 1e-3', 'leakage', leakage);

  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ T, output ] = temperature.compute(Pdyn);
  end
  time = toc(time) / iterationCount;
  fprintf('Average computational time: %.4f s\n', time);

  Utils.plotPowerTemperature(Pdyn, output.Pleak, ...
    T, temperature.samplingInterval);

  Ptot  = mean(Pdyn(:) + output.Pleak(:));
  Pdyn  = mean(Pdyn(:));
  Pleak = mean(output.Pleak(:));

  fprintf('Average total power:        %.2f W\n', Ptot);
  fprintf('Average dynamic power:      %.2f W\n', Pdyn);
  fprintf('Average leakage power:      %.2f W\n', Pleak);
  fprintf('Leakage to dynamic ratio:   %.2f\n', Pleak / Pdyn);
end
