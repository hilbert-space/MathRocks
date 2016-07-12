function count = countSignificant(L, threshold)
  assert(issorted(L(end:-1:1)) && all(L >= 0));
  count = min(length(L), sum(cumsum(L) ./ sum(L) < threshold) + 1);
end
