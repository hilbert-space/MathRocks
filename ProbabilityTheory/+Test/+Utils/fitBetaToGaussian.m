function fitBetaToGaussian
  close all;
  setup;

  mu = 0;
  sigma = 1;

  Gaussian = ProbabilityDistribution.Gaussian( ...
    'mu', mu, 'sigma', sigma);

  a = - 4 * sigma;
  b =   4 * sigma;

  param = Utils.fitBetaToGaussian('sigma', sigma, ...
    'fitRange', [ a, b ], 'paramRange', [ 1, 10 ]);

  Beta = ProbabilityDistribution.Beta( ...
    'alpha', param, 'beta', param, 'a', a, 'b', b);

  x = linspace(a, b, 50);
  f1 = Gaussian.pdf(x);
  f2 = Beta.pdf(x);

  Plot.figure;
  Plot.line(x, f1, 'numer', 1, 'markEach', 2);
  Plot.line(x, f2, 'number', 2, 'markEach', 2);

  Plot.legend( ...
    sprintf('Gaussian (%s, %s^2)', num2str(mu), num2str(sigma)), ...
    sprintf('Beta (%s, %s, %s, %s)', num2str(param), num2str(param), ...
      num2str(a), num2str(b)));
end
