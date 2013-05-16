function HermiteBeta
  setup;

  sampleCount = 1e4;

  distribution = ProbabilityDistribution.Beta( ...
    'alpha', 1.4, 'beta', 3, 'a', 0, 'b', 2);
  variable = RandomVariables.Single('distribution', distribution);

  transformation = ProbabilityTransformation.SingleNormal( ...
    'variables', variable);

  %% Monte Carlo simulations.
  %
  mcData = distribution.sample(sampleCount, 1);

  %% Polynomial chaos expansion.
  %
  chaos = PolynomialChaos.Hermite( ...
    @transformation.evaluate, ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'order', 6, ...
    'quadratureOptions', Options( ...
      'method', 'tensor', ...
      'order', 10));

  display(chaos);

  apData = chaos.evaluate(normrnd(0, 1, sampleCount, 1));

  assess(chaos, apData, mcData, distribution);
end
