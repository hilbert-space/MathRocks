function count = countSignificant(L, threshold)
  assert(issorted(flip(L)) && all(L >= 0));
  count = min(length(L), sum(cumsum(L) ./ sum(L) < threshold) + 1);
end
