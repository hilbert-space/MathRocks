function [ n, L, I ] = chooseSignificant(L, threshold)
  L = max(0, L(:));
  [ L, I ] = sort(L, 'descend');
  n = min(length(L), sum(cumsum(L) ./ sum(L) <= threshold) + 1);
  L = L(1:n);
  I = I(1:n);
end
