function HermiteGaussianN1
  setup;

  distribution = ProbabilityDistribution.Gaussian();

  %
  % NOTE: Supposed to fail.
  %
  assess(@(x) exp(prod(x, 2)), ...
    'basis', 'Hermite', 'inputCount', 2, 'order', 20, ...
    'distribution', distribution, ...
    'quadratureOptions', Options('method', 'sparse'));
end