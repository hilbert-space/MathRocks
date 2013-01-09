setup;

dimension = 10;
domainBoundary = 1;
correlationLength = 1;

kl = KarhunenLoeve.OrnsteinUhlenbeck( ...
  'dimension', dimension, ...
  'domainBoundary', domainBoundary, ...
  'correlationLength', correlationLength);

K = @(s, t) exp(-abs(s - t) / correlationLength);
F = fred(K, domain([ -domainBoundary, domainBoundary ]));
[ psi, lambda ] = eigs(F, dimension, 'lm');
lambda = diag(lambda);

figure;
line(1:dimension, kl.values, 'Marker', 'x');
line(1:dimension, lambda, 'Marker', 'o');
legend('Analytical', 'Numerical (chebfun)');

figure;
r = linspace(-domainBoundary, domainBoundary);
for i = 1:dimension
  color = Color.pick(i);
  f = kl.functions{i};
  line(r, f(r), 'Color', color, 'Marker', 'x');
  f = psi(:, i);
  line(r, f(r), 'Color', color, 'Marker', 'o');
end

samples = 1e3;
z = randn(samples, dimension);
k = zeros(dimension, length(r));

for i = 1:dimension
  f = kl.functions{i};
  k(i, :) = f(r);
end

u = z * diag(sqrt(kl.values)) * k;

[ R1, R2 ] = meshgrid(r, r);
C = cov(u);
mesh(R1, R2, C);
hold on;

C = kl.calculate(R1, R2);
plot3(R1, R2, C, 'k.', 'MarkerSize', 10);
