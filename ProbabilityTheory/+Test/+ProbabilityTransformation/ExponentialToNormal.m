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
  'distribution', distribution, 'correlation', correlation);

%% Transform the dependent RVs into independent ones.
%
transformation = ProbabilityTransformation.Normal( ...
  'variables', rvsDependent);

fprintf('Transformed correlation matrix:\n');
transformation.correlation

%% Sample the transformed RVs.
%
data = transformation.sample(sampleCount);

fprintf('Obtained correlation matrix:\n');
corr(data)

%% Draw the result.
%
Data.observe(data, 'method', 'histogram', 'draw', true);
