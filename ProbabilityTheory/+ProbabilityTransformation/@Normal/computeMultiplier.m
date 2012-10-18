function multiplier = computeMultiplier(this, correlation)
  [ coeff, latent ] = pcacov(correlation);
  multiplier = diag(sqrt(latent)) * coeff.';
end
