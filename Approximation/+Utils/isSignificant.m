function result = isSignificant(L, threshold)
  L = sort(L(:), 'descend');
  result = L(end) / sum(L) < (1 - threshold);
end
