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
distribution = ProbabilityDistribution.Exponential();

%% Construct a vector of correlated RVs.
%
rvsDependent = RandomVariables.Homogeneous( ...
  'distributions', distribution, 'correlation', correlation);

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
Statistic.observe(data, 'method', 'histogram', 'draw', true);
