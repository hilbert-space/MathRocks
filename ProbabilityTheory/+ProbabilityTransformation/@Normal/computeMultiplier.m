function multiplier = computeMultiplier(this, correlation)
  if ~isa(correlation, 'Correlation.Pearson')
    error('The correlation matrix is not supported.');
  end

  [ coeff, latent ] = pcacov(correlation.matrix);
  multiplier = diag(sqrt(latent)) * coeff.';
end
