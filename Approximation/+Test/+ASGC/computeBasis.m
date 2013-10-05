function aij = computeBasis(y, i, j)
  if i == 1
    mi = 1;
  else
    mi = 2^(i - 1) + 1;
  end
  if mi == 1
    yij = 0.5;
  else
    yij = (j - 1) / (mi - 1);
  end
  aij = zeros(size(y));
  I = abs(y - yij) < 1 / (mi - 1);
  aij(I) = 1 - (mi - 1) * abs(y(I) - yij);
end