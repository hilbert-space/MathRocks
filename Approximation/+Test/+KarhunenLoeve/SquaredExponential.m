setup;

dimension = 1;
a = 1;
b = 3;

sigma = 1; % sqrt(1 / a / 4);
correlationLength = 1; % sqrt(1 / b / 2);
domainBoundary = 2;

kl = KarhunenLoeve.SquaredExponential( ...
  'dimension', dimension, 'domainBoundary', domainBoundary, ...
  'correlationLength', correlationLength, 'sigma', sigma);

plot(kl);

kl.values

x = linspace(-domainBoundary, domainBoundary).';

[ C1, C2 ] = kl.evaluate(x, x);

fprintf('Error: %.e\n', norm(C1(:) - C2(:)));

K = @(t, s) sigma^2 * exp(-(t - s).^2 / (2 * correlationLength^2));

F = fred( K, domain([ -domainBoundary, domainBoundary ]) );
[ Psi, Lambda ] = eigs(F, dimension,'lm');

figure;
plot(Psi);

diag(Lambda).'

n = length(x);

[ x1, x2 ] = meshgrid(x, x);

x1 = x1(:);
x2 = x2(:);

C3 = 0;

for i = 1:dimension
  C3 = C3 + Lambda(i) * Psi(x1) .* Psi(x2);
end

C3 = reshape(C3, [ n n ]);
