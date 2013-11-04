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

  switch parameter.model
  case 'Gaussian'
    transformation = ProbabilityTransformation.Gaussian( ...
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
  switch parameter.model
  case 'Gaussian'
    distribution = ProbabilityDistribution.Gaussian( ...
      'mu', contribution * parameter.expectation, ...
      'sigma', sqrt(contribution * parameter.variance));
  case 'Beta'
    a = contribution * min(parameter.range);
    b = contribution * max(parameter.range);

    %
    % Assume that the distribution is symmetric; thus, alpha = beta.
    % These parameters can be computed using
    %
    %                alpha * beta * (b - a)^2
    % Var(X) = ------------------------------------- .
    %          (alpha + bata)^2 * (alpha + beta + 1)
    %
    % Reference:
    %
    % http://en.wikipedia.org/wiki/Beta_distribution#Four_parameters_2
    %
    param = (b - a)^2 / 8 / (contribution * parameter.variance) - 1 / 2;

    distribution = ProbabilityDistribution.Beta( ...
      'alpha', param, 'beta', param, 'a', a, 'b', b);
  otherwise
    assert(false);
  end
end
