clear all;
setup;

sampleCount = 1e4;

distribution = ProbabilityDistribution.Lognormal( ...
  'mu', 0, 'sigma', 0.8);
variables = RandomVariables.Single(distribution);

transformation = ProbabilityTransformation.SingleNormal(variables);

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

Test.PolynomialChaos.assess(chaos, apData, mcData, distribution);
