setup;

approximationMethod = 'LogPolynomialRegression';
errorMetric = 'NRMSE';
iterationCount = 100;

terms = [ ...
  0, 0; ...
  1, 0; ...
  0, 1; ...
  1, 1; ...
  2, 0; ...
  2, 1; ...
];

options = Options('filename', ...
  File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_08.leak'), ...
  'LCount', 50, 'TCount', 50, 'TLimit', Utils.toKelvin([ 0, 400 ]), ...
  'terms', terms);

leakage = LeakagePower.(approximationMethod)(options);
[ Lgrid, Tgrid, Igrid ] = Utils.loadLeakageData(options);

%% Accuracy
%
Ipred = leakage.compute(Lgrid, Tgrid);
error = Error.compute(errorMetric, Igrid, Ipred);

fprintf('%s: %.4f\n', errorMetric, error);

figure;

mesh(Lgrid, Utils.toCelsius(Tgrid), Igrid);
line(Lgrid, Utils.toCelsius(Tgrid), Ipred, ...
  'LineStyle', 'None', ...
  'Marker', 'o', ...
  'MarkerEdgeColor', 'w', ...
  'MarkerFaceColor', 'b');

Plot.title('%s: %s %.4f', approximationMethod, errorMetric, error);
Plot.label('Channel length, m', 'Temperature, C', 'Leakage current, A');

grid on;
view(10, 10);

%% Speed
%
[ Lgrid, Tgrid ] = meshgrid( ...
  linspace(leakage.LRange(1), leakage.LRange(2), 1000), ...
  linspace(leakage.TRange(1), leakage.TRange(2), 1000));

time = tic;
for k = 1:iterationCount
  leakage.compute(Lgrid, Tgrid);
end
fprintf('Computational time: %.4f s\n', toc(time) / iterationCount);
