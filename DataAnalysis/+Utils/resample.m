function M = resample(M, division)
  M = M(:, kron(1:size(M, 2), ones(1, division)));
end
