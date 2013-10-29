function values = evaluate(this, points, I, J, surpluses)
  [ nodes, Li, Mi ] = this.computeNodes(I, J);

  pointCount = size(points, 1);
  outputCount = size(surpluses, 2);

  values = zeros(pointCount, outputCount);

  for i = 1:pointCount
    distances = abs(bsxfun(@minus, nodes, points(i, :)));
    K = all(distances < Li, 2);
    values(i, :) = sum(bsxfun(@times, surpluses(K, :), ...
      prod(1 - (double(Mi(K, :)) - 1) .* distances(K, :), 2)), 1);
  end
end
