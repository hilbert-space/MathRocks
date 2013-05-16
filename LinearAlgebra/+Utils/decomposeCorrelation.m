function mapping = decomposeCorrelation(C, threshold)
  [ V, L ] = pcacov(C);

  if nargin > 1
    [ ~, L, I ] = Utils.chooseSignificant(L, threshold);
    V = V(:, I);
  end

  mapping = V * diag(sqrt(L));
end