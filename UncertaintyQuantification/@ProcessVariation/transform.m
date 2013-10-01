function transformation = transform(~, ...
  parameter, correlation, contribution, ~)

  [ contribution, ~, I ] = unique(contribution);

  distributions = cell(1, length(contribution));
  for i = 1:length(contribution)
    distributions{i} = distribute(parameter.model, ...
      contribution(i) * parameter.expectation, ...
      sqrt(contribution(i) * parameter.variance));
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

function distribution = distribute(model, expectation, standardDeviation)
  switch model
  case 'Gaussian'
    distribution = ProbabilityDistribution.Gaussian( ...
      'mu', expectation, 'sigma', standardDeviation);
  case 'Beta'
    a = -4 * standardDeviation + expectation;
    b =  4 * standardDeviation + expectation;

    param = (b - a)^2 / 8 / standardDeviation^2 - 1 / 2;

    distribution = ProbabilityDistribution.Beta( ...
      'alpha', param, 'beta', param, 'a', a, 'b', b);
  otherwise
    assert(false);
  end
end
