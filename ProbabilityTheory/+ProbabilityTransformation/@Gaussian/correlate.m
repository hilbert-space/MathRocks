function correlation = correlate(this, variables, options)
  dimensionCount = variables.dimensionCount;
  correlation = eye(dimensionCount);

  qd = Quadrature('method', 'tensor', 'dimensionCount', 2, ...
     'ruleName', 'GaussHermiteHW', 'order', 5, ...
     options.get('quadratureOptions', []));

  nodes = qd.nodes;
  weights = qd.weights;

  distribution = this.gaussianDistribution;

  optimizationOptions = options.get( ...
    'optimizationOptions', optimset('TolX', 1e-6));

  for i = 1:dimensionCount
    for j = (i + 1):dimensionCount
      rho0 = variables.correlation(i, j);
      if rho0 == 0, continue; end

      rv1 = variables{i};
      rv2 = variables{j};

      mu1 = rv1.expectation;
      mu2 = rv2.expectation;

      sigma1 = sqrt(rv1.variance);
      sigma2 = sqrt(rv2.variance);

      weightsOne = weights .* (rv1.icdf(distribution.cdf(nodes(:, 1))) - mu1);
      two = @(rho) rv2.icdf(distribution.cdf(rho * nodes(:, 1) + sqrt(1 - rho^2) * nodes(:, 2))) - mu2;
      goal = @(rho) abs(rho0 - sum(weightsOne .* two(rho)) / sigma1 / sigma2);

      correlation(i, j) = fminbnd(goal, -1, 1, optimizationOptions);
      correlation(j, i) = correlation(i, j);
    end
  end
end
