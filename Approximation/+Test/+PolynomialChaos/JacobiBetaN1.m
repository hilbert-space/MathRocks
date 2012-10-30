setup;

use('ProbabilityTheory');
use('Visualization');

order = 6;
sampleCount = 1e5;
dimension = 4;

f = @(x) exp(prod(x, 2));

distribution = ProbabilityDistribution.Beta( ...
  'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);

samples = distribution.sample(sampleCount, dimension);

%% Monte Carlo simulation.
%
mcData = f(samples);

%% Polynomial Chaos expansion.
%
chaos = PolynomialChaos.Jacobi(f, ...
  'order', order, ...
  'inputCount', dimension, ...
  'outputCount', 1, ...
  'quadratureOptions', ...
    Options('method', 'tensor', 'order', 5), ...
  'alpha', distribution.alpha - 1, ...
  'beta', distribution.beta - 1, ...
  'a', distribution.a, ...
  'b', distribution.b);

display(chaos);

apData = chaos.evaluate(samples);

Test.PolynomialChaos.assess(chaos, apData, mcData);
