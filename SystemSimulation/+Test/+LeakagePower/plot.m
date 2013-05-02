setup;

iterationCount = 1e3;

leakage = LeakagePower.LinearInterpolation( ...
  'filename', File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000.leak'));

display(leakage);
plot(leakage);

Lnom = LeakagePower.Base.Lnom;
Ldev = 0.05 * Lnom;
Lmin = Lnom - 5 * Ldev;
Lmax = Lnom + 5 * Ldev;

Tmin = Utils.toKelvin(0);
Tmax = Utils.toKelvin(1000);

L = linspace(Lmin, Lmax, 100);
T = linspace(Tmin, Tmax, 100);

l = zeros(100 * 100, 1);
t = zeros(100 * 100, 1);

k = 0;
for i = 1:100
  for j = 1:100
    k = k + 1;
    l(k) = L(i);
    t(k) = T(j);
  end
end

fprintf('Running %d iterations...\n', iterationCount);
time = tic;
for k = 1:iterationCount
  i = leakage.evaluate(l, t);
end
fprintf('Average computational time: %.4f s\n', toc(time) / iterationCount);

hold on;

plot3(l, Utils.toCelsius(t), i, ...
  'LineStyle', 'None', ...
  'Marker', 'o', ...
  'MarkerEdgeColor', 'none', ...
  'MarkerSize', 2, ...
  'MarkerFaceColor', 'g');

grid on;
