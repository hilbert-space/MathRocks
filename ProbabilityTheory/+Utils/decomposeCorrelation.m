function multiplier = decomposeCorrelation(C, threshold)
  [ V, L ] = pcacov(C);

  if nargin > 1 && threshold < 1
    [ ~, L, I ] = Utils.chooseSignificant(L, threshold);
    V = V(:, I);
  end

  multiplier = V * diag(sqrt(L));
end