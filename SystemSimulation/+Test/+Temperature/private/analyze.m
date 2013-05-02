function analyze(method, analysis, iterationCount)
  setup;

  Pdyn = 2 * dlmread(File.join('+Test', 'Assets', '004.ptrace'), '', 1, 0).';

  leakage = LeakagePower.PolynomialRegression( ...
    'dynamicPower', Pdyn, ...
    'filename', File.join('+Test', 'Assets', 'inverter_45nm.leak'), ...
    'order', [ 1, 2 ], ...
    'scale', [ 1, 0.7, 0; 1, 1, 1 ]);

  hotspot = Temperature.(method).(analysis)( ...
    'floorplan', File.join('+Test', 'Assets', '004.flp'), ...
    'config', File.join('+Test', 'Assets', 'hotspot.config'), ...
    'line', 'sampling_intvl 1e-3', ...
    'leakage', leakage);

  fprintf('Running %d iterations...\n', iterationCount);
  time = tic;
  for i = 1:iterationCount
    [ T, output ] = hotspot.compute(Pdyn);
  end
  time = toc(time) / iterationCount;
  fprintf('Average computational time: %.4f s\n', time);

  T = Utils.toCelsius(T);

  time = hotspot.samplingInterval * (1:size(Pdyn, 2));

  figure;

  subplot(2, 1, 1);

  Plot.title('Temperature profile');
  Plot.label('Time, s', 'Temperature, C');
  Plot.limit(time);
  for i = 1:hotspot.processorCount
    line(time, T(i, :), 'Color', Color.pick(i));
  end

  subplot(2, 1, 2);

  Plot.title('Power profile');
  Plot.label('Time, s', 'Power, W');
  Plot.limit(time);
  for i = 1:hotspot.processorCount
    color = Color.pick(i);
    line(time, Pdyn(i, :), 'Color', color);
    line(time, output.Pleak(i, :), 'Color', color, 'LineStyle', '--');
  end
end
