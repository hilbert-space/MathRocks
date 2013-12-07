function [ M, I ] = decorrelate(V, threshold)
  [ U, L ] = pcacov(V); % sorted in the descending order

  M = U * diag(sqrt(L));
  I = L / sum(L); % importance

  if nargin < 2 || threshold >= 1, return; end

  dimensionCount = Utils.countSignificant(L, threshold);

  M = M(:, 1:dimensionCount);
  I = I(1:dimensionCount);
end