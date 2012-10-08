setup;

samples = 1e6;

alpha = 1;
beta = 3;
a = 2;
b = 5;

distribution = ProbabilityDistribution.Beta( ...
  'alpha', alpha, 'beta', beta, 'a', a, 'b', b);

data = distribution.sample(samples, 1);

observeData(data, 'range', 'unbounded', ...
  'method', 'histogram', 'draw', true);

title(sprintf( ...
  'Empirical PDF of Beta(%.2f, %.2f, %.2f, %.2f)', alpha, beta, a, b));
