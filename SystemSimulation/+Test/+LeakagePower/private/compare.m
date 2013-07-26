function compare(approximationMethod, varargin)
  setup;

  errorMetric = 'NRMSE';
  iterationCount = 100;

  options = Options('filename', ...
    File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_08.leak'), ...
    'VCount', 50, 'TCount', 50, 'TRange', Utils.toKelvin([ 40, 400 ]), ...
    varargin{:});

  leakage = LeakagePower.(approximationMethod)(options);
  [ V, T, I ] = Utils.loadLeakageData(options);

  %
  % Accuracy
  %
  Ipred = leakage.compute(V, T);
  error = Error.compute(errorMetric, I, Ipred);

  fprintf('%s: %.4f\n', errorMetric, error);

  figure;

  mesh(V, Utils.toCelsius(T), I);
  line(V, Utils.toCelsius(T), Ipred, ...
    'LineStyle', 'None', ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'w', ...
    'MarkerFaceColor', 'b');

  Plot.title('%s: %s %.4f', approximationMethod, errorMetric, error);
  Plot.label('Variable', 'Temperature, C', 'Leakage current, A');

  grid on;
  view(10, 10);

  %
  % Speed
  %
  [ V, T ] = meshgrid( ...
    linspace(leakage.VRange(1), leakage.VRange(2), 1000), ...
    linspace(leakage.TRange(1), leakage.TRange(2), 1000));

  time = tic;
  for k = 1:iterationCount
    leakage.compute(V, T);
  end
  fprintf('Computational time: %.4f s\n', toc(time) / iterationCount);
end
