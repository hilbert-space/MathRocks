function analyze(method)
  use('Vendor', 'DataHash');

  Pdyn = 2 * dlmread(File.join('+Test', 'Assets', '04.ptrace'), '', 1, 0).';

  use('SystemSimulation');

  leakage = LeakagePower(Pdyn, ...
    'filename', File.join('+Test', 'Assets', 'inverter_45nm.leak'), ...
    'order', [ 1, 2 ], ...
    'scale', [ 1, 0.7, 0; 1, 1, 1 ]);

  hotspot = HotSpot.(method)( ...
    'floorplan', File.join('+Test', 'Assets', '04.flp'), ...
    'config', File.join('+Test', 'Assets', 'hotspot.config'), ...
    'line', 'sampling_intvl 1e-3');

  [ T, Pleak ] = hotspot.compute(Pdyn, leakage);

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
    line(time, Pleak(i, :), 'Color', color, 'LineStyle', '--');
  end
end
