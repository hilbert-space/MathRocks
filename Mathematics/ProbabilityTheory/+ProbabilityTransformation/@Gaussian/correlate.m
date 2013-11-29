function correlation = correlate(this, variables, options)
  dimensionCount = variables.dimensionCount;
  correlation = eye(dimensionCount);

  quadrature = Quadrature.GaussHermite( ...
    'method', 'tensor', 'level', 4, 'growth', 'slow-linear', ...
    'dimensionCount', 2, options.get('quadratureOptions', []));
  nodes = quadrature.nodes;
  weights = quadrature.weights;

  gaussian = this.gaussianDistribution;

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

      %
      % NOTE: The Gaussian quadrature cannot be directly applied to compute
      % the double integral under consideration since the joint density
      % does not have a product structure (the two variables are dependent).
      % Therefore, we need to have a little linear transformation inside the
      % integrand to make the integration be with respect to independent
      % Gaussian random variables. Another way around, we need to correlate
      % the nodes of the quadrature.
      %
      oneWeights = weights .* (rv1.icdf(gaussian.cdf(nodes(:, 1))) - mu1);
      two = @(rho) rv2.icdf(gaussian.cdf( ...
        rho * nodes(:, 1) + sqrt(1 - rho^2) * nodes(:, 2))) - mu2;

      goal = @(rho) abs(rho0 - sum(oneWeights .* two(rho)) / sigma1 / sigma2);

      correlation(i, j) = fminbnd(goal, -1, 1, optimizationOptions);
      correlation(j, i) = correlation(i, j);
    end
  end
end
