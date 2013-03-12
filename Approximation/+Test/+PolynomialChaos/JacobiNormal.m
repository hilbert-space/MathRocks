function JacobiNormal
  setup;

  sampleCount = 1e4;

  %% Choose a distribution.
  %
  normal = ProbabilityDistribution.Normal( ...
    'mu', 0, 'sigma', 1);
  beta = ProbabilityDistribution.Beta( ...
    'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);

  %% Monte Carlo simulations.
  %
  mcData = normal.sample(sampleCount, 1);

  %% Polynomial chaos expansion.
  %
  chaos = PolynomialChaos.Jacobi( ...
    @(x) normal.icdf(beta.cdf(x)), ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'order', 10, ...
    'alpha', beta.alpha - 1, ...
    'beta', beta.beta - 1, ...
    'a', beta.a, ...
    'b', beta.b, ...
    'quadratureOptions', Options( ...
      'method', 'tensor', ...
      'order', 10));

  display(chaos);

  apData = chaos.evaluate(beta.sample(sampleCount, 1));

  assess(chaos, apData, mcData, normal);
end
