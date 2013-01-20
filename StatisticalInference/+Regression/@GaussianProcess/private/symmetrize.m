function M = symmetrize(V, I)
  a = 1; b = 1; c = -2 * size(I, 1);
  count = (-b + sqrt(b^2 - 4 * a * c)) / 2 / a;

  assert(count > 0 && mod(count, 1) == 0);

  M = zeros(count, count);

  M((I(:, 1) - 1) * count + I(:, 2)) = V;
  M((I(:, 2) - 1) * count + I(:, 1)) = V;
end
