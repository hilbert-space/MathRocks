setup;

approximationMethod = 'LogPolynomialRegression';
errorMetric = 'NRMSE';
iterationCount = 100;

options = Options('filename', ...
  File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_08.leak'), ...
  'LCount', 50, 'TCount', 50, 'TLimit', Utils.toKelvin([ 0, 400 ]), ...
  'order', [ 3, 1 ]);

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
time = tic;
for k = 1:iterationCount
  leakage.compute(Lgrid, Tgrid);
end
fprintf('Computational time: %.4f s\n', toc(time) / iterationCount);
