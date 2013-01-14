function [ n, L, I ] = chooseSignificant(L, threshold)
  [ L, I ] = sort(L(:), 'descend');
  n = min(length(L), sum(L ./ cumsum(L) > (1 - threshold)) + 1);
  L = L(1:n);
  I = I(1:n);
end
