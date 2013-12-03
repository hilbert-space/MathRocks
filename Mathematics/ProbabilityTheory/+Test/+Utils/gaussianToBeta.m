function gaussianToBeta
  setup;

  mu = 22.5e-9;
  sigma = 0.04 * mu;
  range = mu + [ -3, 3 ] * sigma;
  contribution = 0.5;

  gaussian = ProbabilityDistribution.Gaussian( ...
    'mu', mu, 'sigma', sigma);

  gaussian1 = ProbabilityDistribution.Gaussian( ...
    'mu', contribution * mu, 'sigma', sqrt(contribution) * sigma);
  gaussian2 = ProbabilityDistribution.Gaussian( ...
    'mu', (1 - contribution) * mu, 'sigma', sqrt(1 - contribution) * sigma);

  beta1 = Utils.gaussianToBeta(gaussian1, ...
    'target', 'variance', ...
    'a', contribution * range(1), ...
    'b', contribution * range(2));
  beta2 = Utils.gaussianToBeta(gaussian2, ...
    'target', 'variance', ...
    'a', (1 - contribution) * range(1), ...
    'b', (1 - contribution) * range(2));

  Plot.figure(1000, 400);

  subplot(1, 2, 1);
  x = linspace(beta1.a, beta1.b, 50);
  Plot.line(x, gaussian1.pdf(x), 'number', 1, 'markEach', 2);
  Plot.line(x, beta1.pdf(x), 'number', 2, 'markEach', 2);
  Plot.title('Gaussian1 vs. Beta1');
  Plot.legend('Gaussian1', 'Beta1');

  subplot(1, 2, 2);
  x = linspace(beta2.a, beta2.b, 50);
  Plot.line(x, gaussian2.pdf(x), 'number', 1, 'markEach', 2);
  Plot.line(x, beta2.pdf(x), 'number', 2, 'markEach', 2);
  Plot.title('Gaussian2 vs. Beta2');
  Plot.legend('Gaussian2', 'Beta2');

  Plot.figure(800, 400);
  x = linspace(beta1.a + beta2.a, beta1.b + beta2.b, 50);
  Plot.line(x, gaussian.pdf(x), 'number', 1, 'markEach', 2);
  Plot.line(x, convolute(x, beta1, beta2), 'number', 2, 'markEach', 2);
  Plot.vline(range(1), 'number', 3);
  Plot.vline(range(2), 'number', 3);
  Plot.title('Two Gaussians vs. Two Betas');
  Plot.legend('Gaussian1 + Gaussian2', 'Beta1 + Beta2');

  fprintf('Variance error: %e\n', ...
    abs(sigma^2 - beta1.variance - beta2.variance));
end

function fz = convolute(z, X, Y)
  fz = zeros(size(z));

  Sx = X.support;
  Sy = Y.support;

  for i = 1:numel(z)
    S = [ z(i) - Sy(2), z(i) - Sy(1) ];
    S = [ max(Sx(1), S(1)), min(Sx(2), S(2)) ];

    if S(1) >= S(2), continue; end
    S = [ z(i) - S(2), z(i) - S(1) ];
    S = [ max(Sy(1), S(1)), min(Sy(2), S(2)) ];
    if S(1) >= S(2), continue; end

    fz(i) = integral(@(y) X.pdf(z(i) - y) .* Y.pdf(y), S(1), S(2));
  end
end