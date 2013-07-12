setup;

iterationCount = 1e3;

leakage = LeakagePower.LinearInterpolation('filename', ...
  File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000_08.leak'));

display(leakage);
plot(leakage);

[ L, T ] = meshgrid( ...
  linspace(leakage.output.Lmin, leakage.output.Lmax, 100), ...
  linspace(leakage.output.Tmin, leakage.output.Tmax, 100));

fprintf('Running %d iterations...\n', iterationCount);
time = tic;
for k = 1:iterationCount
  leakage.evaluate(L, T);
end
fprintf('Average computational time: %.4f s\n', toc(time) / iterationCount);