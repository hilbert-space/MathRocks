function B = irep(A, M, N)
  [ m, n ] = size(A);
  if (m == 1 && N == 1)
    B = A(ones(M, 1), :);
  elseif (n == 1 && M == 1)
    B = A(:, ones(N, 1));
  else
    error('Not supported.')
  end
end
