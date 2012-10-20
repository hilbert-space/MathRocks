setup;

samples = 1e4;

%% Choose a distribution.
%
distribution = ProbabilityDistribution.Lognormal( ...
  'mu', 0, 'sigma', 0.8);
variables = RandomVariables.Single(distribution);

%% Perform the transformation.
%
transformation = ProbabilityTransformation.SingleNormal(variables);

%% Construct the PC expansion.
%
quadratureOptions = Options( ...
  'name', 'Tensor', ...
  'dimension', 1, ...
  'order', 10);

chaos = PolynomialChaos.ProbabilistHermite( ...
  @transformation.evaluate, ...
  'inputDimension', 1, ...
  'outputDimension', 1, ...
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
mcExp = distribution.expectation;
mcVar = distribution.variance;
mcData = distribution.sample(samples, 1);

fprintf('Error of expectation: %.6f %%\n', ...
  100 * (mcExp - sdExp) / mcExp);
fprintf('Error of variance: %.6f %%\n', ...
  100 * (mcVar - sdVar) / mcVar);

compareData(mcData, sdData, ...
  'draw', true, 'method', 'histogram', 'range', 'unbounded', ...
  'labels', {{ 'Monte Carlo', 'Polynomial chaos' }});
