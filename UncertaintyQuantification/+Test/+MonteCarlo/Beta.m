function Beta
  setup;

  distribution = ProbabilityDistribution.Beta( ...
    'alpha', 1.4, 'beta', 3, 'a', 0, 'b', 2);
  variables = RandomVariables( ...
    'distributions', { distribution }, 'correlation', 1);
  transformation = ProbabilityTransformation.Gaussian( ...
    'variables', variables);

  mc = MonteCarlo('sampleCount', 1e5);
  output = mc.construct(@transformation.evaluate);

  stats = mc.analyze(output);

  fprintf('Absolute error of expectation: %.4f\n', ...
    abs(distribution.expectation - stats.expectation));
  fprintf('Absolute error of variance:    %.4f\n', ...
    abs(distribution.variance - stats.variance));
end
