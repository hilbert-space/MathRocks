function transformation = transform(~, parameter, correlation, options)
  deviation = sqrt(parameter.variance);

  switch parameter.distribution
  case 'Gaussian'
    distribution = ProbabilityDistribution.Gaussian( ...
      'mu', 0, 'sigma', deviation);

    variables = RandomVariables.Homogeneous( ...
      'distributions', distribution, 'correlation', correlation);

    transformation = ProbabilityTransformation.Gaussian( ...
      'variables', variables, ...
      'reductionThreshold', parameter.reductionThreshold);
  case 'Beta'
    a = -4 * deviation;
    b =  4 * deviation;

    param = Utils.fitBetaToNormal('sigma', deviation, ...
      'fitRange', [ a, b ], 'paramRange', [ 1, 20 ]);

    distribution = ProbabilityDistribution.Beta( ...
      'alpha', param, 'beta', param, 'a', a, 'b', b);

    variables = RandomVariables.Homogeneous( ...
      'distributions', distribution, 'correlation', correlation);

    customDistribution = ProbabilityDistribution.Beta( ...
      'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);

    transformation = ProbabilityTransformation.Custom( ...
      'variables', variables, ...
      'reductionThreshold', parameter.reductionThreshold, ...
      'distribution', customDistribution);
  otherwise
    assert(false);
  end
end
