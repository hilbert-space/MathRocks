clear all;
setup;

samples = 1e4;

%% Choose a distribution.
%
distribution = ProbabilityDistribution.Beta( ...
  'alpha', 1.4, 'beta', 3, 'a', 0, 'b', 2);
variable = RandomVariables.Single(distribution);

%% Perform the transformation.
%
transformation = ProbabilityTransformation.SingleNormal(variable);

%% Construct the PC expansion.
%
quadratureOptions = Options( ...
  'name', 'Tensor', ...
  'dimension', 1, ...
  'order', 10);

chaos = PolynomialChaos.Hermite( ...
  @transformation.evaluate, ...
  'inputCount', 1, ...
  'outputCount', 1, ...
  'order', 6, ...
  'quadratureOptions', quadratureOptions);

display(chaos);

%% Sample the expansion.
%
sdExp = chaos.expectation;
sdVar = chaos.variance;
sdData = chaos.evaluate(normrnd(0, 1, samples, 1));

%% Compare.
%
mcData = distribution.sample(samples, 1);
mcExp = distribution.expectation;
mcVar = distribution.variance;

fprintf('Error of expectation: %.6f %%\n', ...
  100 * (mcExp - sdExp) / mcExp);
fprintf('Error of variance: %.6f %%\n', ...
  100 * (mcVar - sdVar) / mcVar);

compareData(mcData, sdData, ...
  'draw', true, 'method', 'histogram', 'range', 'unbounded', ...
  'labels', {{ 'Monte Carlo', 'Polynomial chaos' }});
