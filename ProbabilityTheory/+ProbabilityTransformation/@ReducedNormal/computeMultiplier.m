function multiplier = computeMultiplier(this, correlation)
  [ coeff, latent, explained ] = pcacov(correlation);

  keep = min(find((cumsum(explained) - this.threshold) > 0));
  if isempty(keep), keep = size(coeff, 1); end

  multiplier = diag(sqrt(latent(1:keep))) * coeff(:, 1:keep).';
end
