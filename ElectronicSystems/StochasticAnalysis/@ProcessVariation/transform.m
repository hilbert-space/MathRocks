function transformation = transform(~, ...
  parameter, correlation, contribution, ~)

  [ contribution, ~, I ] = unique(contribution);

  distributions = cell(1, length(contribution));
  for i = 1:length(contribution)
    distributions{i} = distribute(parameter, contribution(i));
  end
  distributions = distributions(I);

  variables = RandomVariables( ...
    'distributions', distributions, 'correlation', correlation);

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

function distribution = distribute(parameter, contribution)
  switch parameter.distribution
  case 'Gaussian'
    distribution = ProbabilityDistribution.Gaussian( ...
      'mu', contribution * parameter.expectation, ...
      'sigma', sqrt(contribution * parameter.variance));
  case 'Beta'
    gaussian = ProbabilityDistribution.Gaussian( ...
      'mu', contribution * parameter.expectation, ...
      'sigma', sqrt(contribution * parameter.variance));

    %
    % NOTE: When the a and b parameters of gaussianToBeta are not
    % specified, the support of the beta distribution will be
    %
    %  [ a, b ] = gaussian.mu + [ -spread, spread ] * gaussian.sigma,
    %
    % which is
    %
    %  sqrt(contribution) * parameter.range,
    %
    % not
    %
    %  contribution * parameter.range.
    %
    % Therefore, the range of the parameter will not be preserved.
    % On the other hand, if we enforce the desired range, i.e.,
    %
    % [ a, b ] = contribution * parameter.range,
    %
    % the shape of the resulting PDF will be substantially different
    % from Gaussian bell shapes.
    %
    % Also, if the target parameter is set to "pdf," the resulting
    % variance will not match the desired one, i.e.,
    %
    % contribution * parameter.variance
    %
    distribution = Utils.gaussianToBeta( ...
      gaussian, 'target', 'variance', 'spread', 3);
  otherwise
    assert(false);
  end
end
