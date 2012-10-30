setup;

use('TemperatureAnalysis');
use('Vendor', 'DataHash');

leakage = LeakagePower( ...
  'filename', File.join(File.trace, 'Assets', 'inverter_45nm.leak'), ...
  'order', [ 1 2 ], ...
  'scale', [ 1, 0.7, 0; 1, 1, 1 ]);

plot(leakage);

Lnom = LeakagePower.Lnom;
Ldev = 0.05 * Lnom;

Tref = Utils.toKelvin(27);

T = linspace(Tref, Tref + 123, 100);
L = linspace(Lnom - 4 * Ldev, Lnom + 4 * Ldev, 100);

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

i = leakage.predict(l, t) / leakage.predict(Lnom, Tref);

hold on;

plot3(l, t, i, ...
  'LineStyle', 'None', ...
  'Marker', 'o', ...
  'MarkerEdgeColor', 'none', ...
  'MarkerSize', 2, ...
  'MarkerFaceColor', 'g');

grid on;
