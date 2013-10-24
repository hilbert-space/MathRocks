function values = evaluate(this, points, I, surpluses)
  [ indexCount, dimensionCount ] = size(I);
  pointCount = size(points, 1);
  outputCount = size(surpluses, 2);

  [ nodes, offsets, counts, Li, Mi ] = this.computeNodes(I);

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
    I = all(distances < L, 2);
    values(i, :) = sum(bsxfun(@times, surpluses(I, :), ...
      prod(1 - (M(I, :) - 1) .* distances(I, :), 2)), 1);
  end
end
