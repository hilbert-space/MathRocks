function [ n, L, I ] = chooseSignificant(L, threshold)
  assert(all(L >= 0));
  [ L, I ] = sort(L, 'descend');
  n = sum(cumsum(L) ./ sum(L) < threshold) + 1;
  L = L(1:n);
  I = I(1:n);
end
