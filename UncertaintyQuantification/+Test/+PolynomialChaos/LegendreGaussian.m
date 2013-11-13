function LegendreGaussian
  setup;

  gaussian = ProbabilityDistribution.Gaussian('mu', 0, 'sigma', 1);
  uniform = ProbabilityDistribution.Uniform('a', -1, 'b', 1);

  assess(@(x) gaussian.icdf(uniform.cdf(x)), ...
    'basis', 'Legendre', 'order', 10, ...
    'a', uniform.a, 'b', uniform.b, ...
    'distribution', gaussian);
end
