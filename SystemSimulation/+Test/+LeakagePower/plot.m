setup;

iterationCount = 10;
pointCount = 5000;

leakage = LeakagePower.PolynomialRegression('filename', ...
  File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_08.leak'), ...
  'LCount', 50, 'TCount', 50, 'TLimit', Utils.toKelvin([ 0, 400 ]), ...
  'order', [ 3, 2 ]);

display(leakage);
plot(leakage);

[ L, T ] = meshgrid( ...
  linspace(leakage.output.Lmin, leakage.output.Lmax, pointCount), ...
  linspace(leakage.output.Tmin, leakage.output.Tmax, pointCount));

fprintf('Running %d iterations...\n', iterationCount);
time = tic;
for k = 1:iterationCount
  leakage.evaluate(L, T);
end
fprintf('Average computational time: %.4f s\n', toc(time) / iterationCount);