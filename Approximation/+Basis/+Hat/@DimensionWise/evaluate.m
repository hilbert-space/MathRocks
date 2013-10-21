function values = evaluate(this, Y, I, C)
  [ indexCount, dimensionCount ] = size(I);
  pointCount = size(Y, 1);
  outputCount = size(C, 2);

  [ Yij, offsets, counts, Li, Mi ] = this.computeNodes(I);

  nodeCount = size(Yij, 1);
  assert(nodeCount == size(C, 1));

  L = zeros(nodeCount, dimensionCount);
  M = L;
  for i = 1:indexCount
    range = (offsets(i) + 1):(offsets(i) + counts(i));
    L(range, :) = repmat(Li(i, :), counts(i), 1);
    M(range, :) = repmat(double(Mi(i, :)), counts(i), 1);
  end

  values = zeros(pointCount, outputCount);

  D = zeros(nodeCount, dimensionCount);
  K = false(nodeCount, 1);

  for i = 1:pointCount
    D(:, :) = abs(bsxfun(@minus, Yij, Y(i, :)));
    K(:) = all(D < L, 2);
    values(i, :) = sum(bsxfun(@times, C(K, :), ...
      prod(1 - (M(K, :) - 1) .* D(K, :), 2)), 1);
  end
end
