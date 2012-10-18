setup;

samples = 1e6;
dimension = 4;

%% Generate a correlation matrix.
%
C0 = Utils.generateCorrelation(dimension);

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
C1 = corr(data);

%% Transformation with reduction.
%
transformation = ProbabilityTransformation.ReducedNormal(rvsDependent);
data = transformation.sample(samples);
C2 = corr(data);

fprintf('Initial dimensions: %d\n', dimension);
fprintf('Reduced dimensions: %d\n', transformation.dimension);

fprintf('Infinity norm without reduction: %e\n', norm(C0 - C1, Inf));
fprintf('Infinity norm with reduction:    %e\n', norm(C0 - C2, Inf));

data = mvnrnd(zeros(dimension, 1), C0, samples);
C3 = corr(data);

fprintf('Infinity norm with empirical:    %e\n', norm(C0 - C3, Inf));
