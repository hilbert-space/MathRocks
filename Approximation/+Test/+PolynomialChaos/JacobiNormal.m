function JacobiNormal
  setup;

  sampleCount = 1e4;

  normal = ProbabilityDistribution.Gaussian( ...
    'mu', 0, 'sigma', 1);
  beta = ProbabilityDistribution.Beta( ...
    'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);

  mcData = normal.sample(sampleCount, 1);

  surrogate = PolynomialChaos.Jacobi( ...
    'inputCount', 1, 'outputCount', 1, 'order', 10, ...
    'alpha', beta.alpha - 1, ...
    'beta', beta.beta - 1, ...
    'a', beta.a, ...
    'b', beta.b);

  surrogateOutput = surrogate.expand(@(x) normal.icdf(beta.cdf(x)));
  surrogateData = surrogate.evaluate(surrogateOutput, beta.sample(sampleCount, 1));

  assess(mcData, surrogate, surrogateOutput, surrogateData, normal);
end
