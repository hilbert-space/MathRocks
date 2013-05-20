function fitBetaToNormal
  close all;
  setup;

  mu = 0;
  sigma = 1;

  Normal = ProbabilityDistribution.Normal( ...
    'mu', mu, 'sigma', sigma);

  a = - 4 * sigma;
  b =   4 * sigma;

  param = Utils.fitBetaToNormal('sigma', sigma, ...
    'fitRange', [ a, b ], 'paramRange', [ 1, 10 ]);

  Beta = ProbabilityDistribution.Beta( ...
    'alpha', param, 'beta', param, 'a', a, 'b', b);

  x = linspace(a, b, 50);
  f1 = Normal.pdf(x);
  f2 = Beta.pdf(x);

  figure;
  line(x, f1, 'Color', Color.pick(1));
  line(x, f2, 'Color', Color.pick(2));

  Plot.legend( ...
    sprintf('Normal (%s, %s^2)', num2str(mu), num2str(sigma)), ...
    sprintf('Beta (%s, %s, %s, %s)', num2str(param), num2str(param) ,...
      num2str(a), num2str(b)));
end
