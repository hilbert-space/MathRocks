function result = isIndependent(matrix)
  result = norm(matrix - eye(size(matrix, 1)), Inf) == 0;
end
