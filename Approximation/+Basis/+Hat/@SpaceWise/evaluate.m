function values = evaluate(this, Y, I, J, C)
  [ Yij, Li, Mi ] = this.computeNodes(I, J);

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
