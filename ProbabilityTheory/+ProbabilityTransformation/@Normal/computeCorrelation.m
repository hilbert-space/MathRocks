function correlation = computeCorrelation(this, rvs)
  dimension = rvs.dimension;

  qd = Quadrature.Tensor('rules', 'GaussHermite', this.quadratureOptions);
  nodes = qd.nodes;
  weights = qd.weights;

  normal = this.normal;

  matrix = diag(ones(1, dimension));

  %
  % Just to eliminate unnecessary work if the RVs are independent.
  %
  if dimension == 1 || norm(matrix - rvs.correlation.matrix, Inf) == 0
    dimension = 0;
  end

  for i = 1:dimension
    for j = (i + 1):dimension
      rv1 = rvs{i};
      rv2 = rvs{j};

      mu1 = rv1.expectation;
      mu2 = rv2.expectation;

      sigma1 = sqrt(rv1.variance);
      sigma2 = sqrt(rv2.variance);

      rho0 = rvs.correlation(i, j);

      weightsOne = weights .* (rv1.invert(normal.apply(nodes(:, 1))) - mu1);
      two = @(rho) rv2.invert(normal.apply(rho * nodes(:, 1) + sqrt(1 - rho^2) * nodes(:, 2))) - mu2;
      goal = @(rho) abs(rho0 - sum(weightsOne .* two(rho)) / sigma1 / sigma2);

      [ matrix(i, j), ~, ~, out ] = fminbnd(goal, -1, 1, this.optimizationOptions);

      matrix(j, i) = matrix(i, j);
    end
  end

  correlation = Correlation.Pearson(matrix);
end
