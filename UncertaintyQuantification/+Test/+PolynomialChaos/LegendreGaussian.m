function LegendreGaussian
  setup;

  gaussian = ProbabilityDistribution.Gaussian('mu', 0, 'sigma', 1);
  uniform = ProbabilityDistribution.Uniform('a', 0, 'b', 1);

  assess(@(x) gaussian.icdf(uniform.cdf(x)), ...
    'basis', 'Legendre', 'order', 15, ...
    'distribution', uniform, ...
    'exact', gaussian);
end
