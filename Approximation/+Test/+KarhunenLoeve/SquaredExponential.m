setup;

dimension = 4;
domainBoundary = 1;
correlationLength = 1;
sigma = 1;

kl = KarhunenLoeve.SquaredExponential( ...
  'dimension', dimension, 'domainBoundary', domainBoundary, ...
  'correlationLength', correlationLength, 'sigma', sigma);

K = @(s, t) sigma^2 * exp(-(s - t).^2 / (2 * correlationLength^2));
F = fred(K, domain([ -domainBoundary, domainBoundary ]));
[ psi, lambda ] = eigs(F, dimension, 'lm');
lambda = diag(lambda);

figure;
line(1:dimension, kl.values, 'Marker', 'x');
line(1:dimension, lambda, 'Marker', 'o');
legend('Approximation', 'Numerical (chebfun)');

figure;
x = linspace(-domainBoundary, domainBoundary);
for i = 1:dimension
  color = Color.pick(i);
  f = kl.functions{i};
  line(x, f(x), 'Color', color, 'Marker', 'x');
  f = psi(:, i);
  line(x, f(x), 'Color', color, 'Marker', 'o');
end
