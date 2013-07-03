function S = stretch(M, length)
  [ rows, cols ] = size(M);
  S = zeros(rows, length);
  packed = 0;
  while (packed < length)
    topack = min(length - packed, cols);
    S(:, (packed + 1):(packed + topack)) = M(:, 1:topack);
    packed = packed + topack;
  end
end
