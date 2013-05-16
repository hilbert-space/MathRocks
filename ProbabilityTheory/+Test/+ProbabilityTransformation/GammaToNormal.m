setup;

sampleCount = 1e6;

%% Generate a correlation matrix.
%
correlation = [ 1 -0.7; -0.7 1 ];
fprintf('Desired correlation matrix:\n');
correlation

%% Define the marginal distributions.
%
distributions = { ...
  ProbabilityDistribution.Gamma('a', 2, 'b', 3), ...
  ProbabilityDistribution.Gamma('a', 2, 'b', 3), ...
};

%% Construct a vector of correlated RVs.
%
rvsDependent = RandomVariables.Heterogeneous( ...
  'distributions', distributions, 'correlation', correlation);

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
