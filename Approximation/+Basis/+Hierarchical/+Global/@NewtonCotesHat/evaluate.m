function values = evaluate(this, points, indexes, surpluses)
  [ indexCount, dimensionCount ] = size(indexes);
  pointCount = size(points, 1);
  outputCount = size(surpluses, 2);

  [ nodes, offsets, counts, Li, Mi ] = this.computeNodes(indexes);

  nodeCount = size(nodes, 1);
  assert(nodeCount == size(surpluses, 1));

  L = zeros(nodeCount, dimensionCount);
  M = zeros(nodeCount, dimensionCount);
  for i = 1:indexCount
    range = (offsets(i) + 1):(offsets(i) + counts(i));
    L(range, :) = repmat(Li(i, :), counts(i), 1);
    M(range, :) = repmat(double(Mi(i, :)), counts(i), 1);
  end

  values = zeros(pointCount, outputCount);

  for i = 1:pointCount
    distances = abs(bsxfun(@minus, nodes, points(i, :)));
    indexes = all(distances < L, 2);
    values(i, :) = sum(bsxfun(@times, surpluses(indexes, :), ...
      prod(1 - (M(indexes, :) - 1) .* distances(indexes, :), 2)), 1);
  end
end
