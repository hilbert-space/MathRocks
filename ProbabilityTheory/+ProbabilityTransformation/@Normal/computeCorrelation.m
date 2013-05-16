function correlation = computeCorrelation(this, rvs)
  dimensionCount = rvs.dimensionCount;

  qd = Quadrature(this.quadratureOptions, ...
    'method', 'tensor', 'dimension', 2, 'ruleName', 'GaussHermiteHW');

  nodes = qd.nodes;
  weights = qd.weights;

  distribution = this.distribution;

  correlation = eye(dimensionCount);

  %
  % Just to eliminate unnecessary work if the RVs are independent.
  %
  if dimensionCount == 1 || rvs.isIndependent(), return; end

  for i = 1:dimensionCount
    for j = (i + 1):dimensionCount
      rv1 = rvs{i};
      rv2 = rvs{j};

      mu1 = rv1.expectation;
      mu2 = rv2.expectation;

      sigma1 = sqrt(rv1.variance);
      sigma2 = sqrt(rv2.variance);

      rho0 = rvs.correlation(i, j);

      weightsOne = weights .* (rv1.icdf(distribution.cdf(nodes(:, 1))) - mu1);
      two = @(rho) rv2.icdf(distribution.cdf(rho * nodes(:, 1) + sqrt(1 - rho^2) * nodes(:, 2))) - mu2;
      goal = @(rho) abs(rho0 - sum(weightsOne .* two(rho)) / sigma1 / sigma2);

      correlation(i, j) = fminbnd(goal, -1, 1, this.optimizationOptions);
      correlation(j, i) = correlation(i, j);
    end
  end
end
