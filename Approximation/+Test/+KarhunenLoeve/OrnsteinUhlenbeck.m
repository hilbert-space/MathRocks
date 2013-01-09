setup;

dimension = 20;
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
x = linspace(-domainBoundary, domainBoundary);
for i = [ 1 2 5 10 ]
  color = Color.pick(i);
  f = kl.functions{i};
  line(x, f(x), 'Color', color, 'Marker', 'x');
  f = psi(:, i);
  line(x, f(x), 'Color', color, 'Marker', 'o');
end
