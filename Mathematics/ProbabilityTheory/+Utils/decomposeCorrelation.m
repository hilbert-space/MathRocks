function [ M, I ] = decomposeCorrelation(C, threshold)
  [ V, L ] = pcacov(C); % sorted
  M = V * diag(sqrt(L));
  I = L / sum(L);

  if nargin < 2 || threshold >= 1, return; end

  count = Utils.countSignificant(L, threshold);
  M = M(:, 1:count);
  I = I(1:count);
end