function values = evaluate(this, Y, I, C)
  indexCount = size(I, 1);

  [ Yij, offsets, counts, Li, Mi ] = this.computeNodes(I);
  assert(size(Yij, 1) == size(C, 1));

  mapping = zeros(sum(counts), 1, 'uint16');
  for i = 1:indexCount
    mapping((offsets(i) + 1):(offsets(i) + counts(i))) = i;
  end

  Li = Li(mapping, :);
  Mi = Mi(mapping, :);

  pointCount = size(Y, 1);
  outputCount = size(C, 2);

  values = zeros(pointCount, outputCount);

  for i = 1:pointCount
    delta = abs(bsxfun(@minus, Yij, Y(i, :)));
    K = all(delta < Li, 2);
    values(i, :) = sum(bsxfun(@times, C(K, :), ...
      prod(1 - (double(Mi(K, :)) - 1) .* delta(K, :), 2)), 1);
  end
end
