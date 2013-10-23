function JacobiBetaN1
  setup;

  order = 7;
  sampleCount = 1e5;
  inputCount = 4;

  f = @(x) exp(prod(x, 2));

  distribution = ProbabilityDistribution.Beta( ...
    'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);

  samples = distribution.sample(sampleCount, inputCount);

  mcData = f(samples);

  surrogate = PolynomialChaos.Jacobi( ...
    'inputCount', inputCount, 'outputCount', 1, 'order', order, ...
    'alpha', distribution.alpha - 1, ...
    'beta', distribution.beta - 1, ...
    'a', distribution.a, ...
    'b', distribution.b, ...
    'quadratureOptions', Options('method', 'sparse'));

  surrogateOutput = surrogate.expand(f);
  surrogateData = surrogate.evaluate(surrogateOutput, samples);

  assess(mcData, surrogate, surrogateOutput, surrogateData);
end
