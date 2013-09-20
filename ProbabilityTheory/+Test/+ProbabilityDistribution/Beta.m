setup;

sampleCount = 1e6;

alpha = 1;
beta = 3;
a = 2;
b = 5;

distribution = ProbabilityDistribution.Beta( ...
  'alpha', alpha, 'beta', beta, 'a', a, 'b', b);

data = distribution.sample(sampleCount, 1);

Statistic.observe(data, 'range', 'unbounded', ...
  'method', 'histogram', 'draw', true);

Plot.title(sprintf( ...
  'Empirical PDF of Beta(%.2f, %.2f, %.2f, %.2f)', alpha, beta, a, b));
