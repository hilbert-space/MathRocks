function correlation = generateCorrelation(dimension)
  S = randn(dimension);
  S = S' * S;
  correlation = corrcov(S);
end
