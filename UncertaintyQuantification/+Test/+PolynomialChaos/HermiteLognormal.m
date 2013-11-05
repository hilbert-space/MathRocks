function HermiteLognormal
  setup;

  sampleCount = 1e4;

  distribution = ProbabilityDistribution.Lognormal( ...
    'mu', 0, 'sigma', 0.8);
  variables = RandomVariables( ...
    'distributions', { distribution }, 'correlation', 1);

  transformation = ProbabilityTransformation.Gaussian( ...
    'variables', variables);

  mcData = distribution.sample(sampleCount, 1);

  surrogate = PolynomialChaos.Hermite( ...
    'inputCount', 1, 'outputCount', 1, 'order', 6);

  surrogateOutput = surrogate.expand(@transformation.evaluate);
  surrogateData = surrogate.evaluate(surrogateOutput, normrnd(0, 1, sampleCount, 1));

  assess(mcData, surrogate, surrogateOutput, surrogateData, distribution);
end
