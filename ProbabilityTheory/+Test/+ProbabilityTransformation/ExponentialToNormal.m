setup;

samples = 1e6;
dimension = 2;

%% Generate a correlation matrix.
%
correlation = Correlation.Pearson.random(dimension);
fprintf('Desired correlation matrix:\n');
correlation

%% Define the marginal distributions.
%
distribution = ProbabilityDistribution.Exponential();

%% Construct a vector of correlated RVs.
%
rvsDependent = RandomVariables.Homogeneous( ...
  distribution, correlation);

%% Transform the dependent RVs into independent ones.
%
transformation = ProbabilityTransformation.Normal(rvsDependent);

fprintf('Transformed correlation matrix:\n');
transformation.correlation

%% Sample the transformed RVs.
%
data = transformation.sample(samples);

fprintf('Obtained correlation matrix:\n');
Correlation.Pearson.compute(data)

%% Draw the result.
%
Statistics.observe(data, 'method', 'histogram', 'draw', true);
