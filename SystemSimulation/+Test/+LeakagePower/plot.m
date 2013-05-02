setup;

leakage = LeakagePower.PolynomialRegression( ...
  'filename', File.join('+Test', 'Assets', 'inverter_45nm_L5_T1000.leak'), ...
  'order', [ 1 2 ], ...
  'scale', [ 1, 1, 1; 1, 1, 1 ]);

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

i = leakage.evaluate(l, t);

hold on;

plot3(l, Utils.toCelsius(t), i, ...
  'LineStyle', 'None', ...
  'Marker', 'o', ...
  'MarkerEdgeColor', 'none', ...
  'MarkerSize', 2, ...
  'MarkerFaceColor', 'g');

grid on;
