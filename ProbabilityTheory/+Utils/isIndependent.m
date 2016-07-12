function result = isIndependent(matrix)
  result = isscalar(matrix) || ...
    (norm(matrix - eye(size(matrix, 1)), Inf) == 0);
end
