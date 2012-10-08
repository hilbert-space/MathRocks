setup;

samples = 1e6;
dimension = 4;

%% Generate a correlation matrix.
%
C0 = Correlation.Pearson.random(dimension);

%% Define the marginal distributions.
%
distribution = ProbabilityDistribution.Normal();

%% Construct a vector of correlated RVs.
%
rvsDependent = RandomVariables.Homogeneous(distribution, C0);

%% Transformation without reduction.
%
transformation = ProbabilityTransformation.Normal(rvsDependent);
data = transformation.sample(samples);
C1 = Correlation.Pearson.compute(data);

%% Transformation with reduction.
%
transformation = ProbabilityTransformation.ReducedNormal(rvsDependent);
data = transformation.sample(samples);
C2 = Correlation.Pearson.compute(data);

fprintf('Initial dimensions: %d\n', dimension);
fprintf('Reduced dimensions: %d\n', transformation.dimension);

fprintf('Infinity norm without reduction: %e\n', ...
  norm(C0.matrix - C1.matrix, Inf));
fprintf('Infinity norm with reduction:    %e\n', ...
  norm(C0.matrix - C2.matrix, Inf));

data = mvnrnd(zeros(dimension, 1), C0.matrix, samples);
C3 = Correlation.Pearson.compute(data);

fprintf('Infinity norm with empirical:    %e\n', ...
  norm(C0.matrix - C3.matrix, Inf));
