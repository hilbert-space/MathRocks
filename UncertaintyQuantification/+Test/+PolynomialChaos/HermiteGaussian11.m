function HermiteGaussian11
  setup;

  distribution = ProbabilityDistribution.Gaussian();

  %
  % NOTE: Supposed to fail.
  %
  assess(@(x) 1 ./ (x - 1), ...
    'basis', 'Hermite', 'order', 2, ...
    'distribution', distribution, ...
    'quadratureOptions', Options('method', 'tensor'));
end