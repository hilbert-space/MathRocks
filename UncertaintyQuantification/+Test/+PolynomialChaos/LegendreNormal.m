function LegendreNormal
  setup;

  sampleCount = 1e4;

  normal = ProbabilityDistribution.Gaussian( ...
    'mu', 0, 'sigma', 1);
  uniform = ProbabilityDistribution.Uniform( ...
    'a', -1, 'b', 1);

  mcData = normal.sample(sampleCount, 1);

  surrogate = PolynomialChaos.Legendre( ...
    'inputCount', 1, 'outputCount', 1, 'order', 10);

  surrogateOutput = surrogate.expand(@(x) normal.icdf(uniform.cdf(x)));
  surrogateData = surrogate.evaluate(surrogateOutput, uniform.sample(sampleCount, 1));

  assess(mcData, surrogate, surrogateOutput, surrogateData, normal);
end
