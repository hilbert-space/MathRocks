setup;

sampleCount = 1e6;
dimensionCount = 4;

%% Generate a correlation matrix.
%
C0 = Utils.generateCorrelation(dimensionCount);

%% Define the marginal distributions.
%
distributions = repmat( ...
  { ProbabilityDistribution.Gaussian }, 1, dimensionCount);

%% Construct a vector of correlated RVs.
%
rvsDependent = RandomVariables( ...
  'distributions', distributions, 'correlation', C0);

%% Transformation without reduction.
%
transformation = ProbabilityTransformation.Uniform( ...
  'variables', rvsDependent);
data1 = transformation.sample(sampleCount);
C1 = corr(data1);

%% Transformation with reduction.
%
transformation = ProbabilityTransformation.Uniform( ...
  'variables', rvsDependent, 'reductionThreshold', 0.99);
data2 = transformation.sample(sampleCount);
C2 = corr(data2);

fprintf('Initial dimensions: %d\n', dimensionCount);
fprintf('Reduced dimensions: %d\n', transformation.dimensionCount);

fprintf('Infinity norm without reduction: %e\n', norm(C0 - C1, Inf));
fprintf('Infinity norm with reduction:    %e\n', norm(C0 - C2, Inf));

data3 = mvnrnd(zeros(dimensionCount, 1), C0, sampleCount);
C3 = corr(data3);

fprintf('Infinity norm with empirical:    %e\n', norm(C0 - C3, Inf));

%% Draw the result.
%
Utils.compareDistributions(data1, data3, 'method', 'histogram');
Plot.name('Without reduction vs. Empirical');
Utils.compareDistributions(data2, data3, 'method', 'histogram');
Plot.name('With reduction vs. Empirical');
