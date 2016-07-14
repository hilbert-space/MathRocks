function transformation = transform(~, parameter, correlation, ~)
  gaussian = ProbabilityDistribution.Gaussian( ...
    'mu', parameter.expectation, 'sigma', sqrt(parameter.variance));

  switch parameter.distribution
  case 'Gaussian'
    distribution = gaussian;
  case 'Beta'
    %
    % NOTE: When the a and b parameters of gaussianToBeta are not
    % specified, the support of the beta distribution will be
    %
    %  [a, b] = gaussian.mu + [-spread, spread] * gaussian.sigma
    %
    % where spread is equal to three by default. Also, if the target
    % parameter is set to "pdf," the resulting variance will not match
    % exactly the desired one, i.e., parameter.variance.
    %
    distribution = Utils.gaussianToBeta(gaussian, ...
      'target', 'variance', 'a', parameter.range(1), 'b', parameter.range(2));
  otherwise
    assert(false);
  end

  distributions = repmat({ distribution }, 1, size(correlation, 2));

  variables = RandomVariables('distributions', distributions, ...
    'correlation', correlation);

  switch parameter.transformation
  case 'Gaussian'
    transformation = ProbabilityTransformation.Gaussian( ...
      'variables', variables, ...
      'reductionThreshold', parameter.reductionThreshold);
  case 'Uniform'
    transformation = ProbabilityTransformation.Uniform( ...
      'variables', variables, ...
      'reductionThreshold', parameter.reductionThreshold);
  case 'Beta'
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
