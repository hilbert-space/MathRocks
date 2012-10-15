setup;

samples = 1e4;

%% Choose a distribution.
%
distribution = ProbabilityDistribution.Lognormal( ...
  'normalMu', 0, 'normalSigma', 0.7);
variables = RandomVariables.Single(distribution);

%% Perform the transformation.
%
transformation = ProbabilityTransformation.SingleNormal(variables);

%% Construct the PC expansion.
%
quadratureOptions = Options('rules', 'GaussHermite', 'level', 10);
chaos = PolynomialChaos.Hermite('order', 5, ...
  'quadratureName', 'Sparse', ...
  'quadratureOptions', quadratureOptions);

%% Sample the expansion.
%
[ sdExp, sdVar, sdData ] = chaos.sample( ...
  @transformation.evaluateNative, samples);

%% Compare.
%
mcData = distribution.sample(samples, 1);
mcExp = distribution.mu;
mcVar = distribution.sigma^2;

fprintf('Error of expectation: %.2f %%\n', ...
  100 * (mcExp - sdExp) / mcExp);
fprintf('Error of variance: %.2f %%\n', ...
  100 * (mcVar - sdVar) / mcVar);

compareData(mcData, sdData, ...
  'draw', true, 'method', 'histogram', 'range', 'unbounded', ...
  'labels', {{ 'Monte Carlo', 'Polynomial chaos' }});
