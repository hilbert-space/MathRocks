function JacobiBeta11
  setup;

  use('ProbabilityTheory');
  use('Visualization');

  order = 1;
  sampleCount = 1e5;

  f = @(x) x;

  distribution = ProbabilityDistribution.Beta( ...
    'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);

  samples = distribution.sample(sampleCount, 1);

  %% Monte Carlo simulation.
  %
  mcData = f(samples);

  %% Polynomial Chaos expansion.
  %
  chaos = PolynomialChaos.Jacobi(f, ...
    'order', order, ...
    'inputCount', 1, ...
    'outputCount', 1, ...
    'quadratureOptions', ...
      Options('method', 'tensor', 'order', 4), ...
    'alpha', distribution.alpha - 1, ...
    'beta', distribution.beta - 1, ...
    'a', distribution.a, ...
    'b', distribution.b);

  display(chaos);

  apData = chaos.evaluate(samples);

  assess(chaos, apData, mcData, distribution);
end
