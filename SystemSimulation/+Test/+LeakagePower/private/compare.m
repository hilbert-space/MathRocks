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

  computeLinearized = Utils.linearizeLeakage(leakage, ...
    'TRange', Utils.toKelvin([ 40, 120 ]));

  %
  % Accuracy
  %
  figure('Position', [ 100, 800, 1200, 400 ]);

  names = { 'Model', 'Linearized model' };

  Ipred = cell(1, 2);
  errors = zeros(1, 2);

  Ipred{1} = leakage.compute(V, T);
  Ipred{2} = computeLinearized(V, T);

  errors(1) = Error.compute(errorMetric, I, Ipred{1});
  errors(2) = Error.compute(errorMetric, I, Ipred{2});

  fprintf('%s of the model (linearized): %.4f (%.4f)\n', errorMetric, errors(1), errors(2));

  for i = 1:2
    subplot(1, 2, i);
    mesh(V, Utils.toCelsius(T), I);
    line(V, Utils.toCelsius(T), Ipred{i}, ...
      'LineStyle', 'None', 'Marker', 'o', ...
      'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'b');

    Plot.title('%s: %s %.4f', names{i}, errorMetric, errors(i));
    Plot.label('Variable', 'Temperature, C', 'Leakage current, A');

    grid on;
    view(10, 10);
  end

  Plot.name(approximationMethod);

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
