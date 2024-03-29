setup;

sampleCount = 1e6;
dimensionCount = 2;

%% Generate a correlation matrix.
%
correlation = Utils.generateCorrelation(dimensionCount);
fprintf('Desired correlation matrix:\n');
correlation

%% Define the marginal distributions.
%
distributions = repmat( ...
  { ProbabilityDistribution.Exponential }, 1, dimensionCount);

%% Construct a vector of correlated RVs.
%
rvsDependent = RandomVariables( ...
  'distributions', distributions, 'correlation', correlation);

%% Transform the dependent RVs into independent ones.
%
transformation = ProbabilityTransformation.Gaussian( ...
  'variables', rvsDependent);

%% Sample the transformed RVs.
%
data = transformation.sample(sampleCount);

fprintf('Empirical correlation matrix:\n');
corr(data)

%% Draw the result.
%
Plot.distribution(data, 'method', 'histogram');
