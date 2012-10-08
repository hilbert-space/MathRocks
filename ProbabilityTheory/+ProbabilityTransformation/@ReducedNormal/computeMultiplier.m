function multiplier = computeMultiplier(this, correlation)
  if ~isa(correlation, 'Correlation.Pearson')
    error('The correlation matrix is not supported.');
  end

  [ coeff, latent, explained ] = pcacov(correlation.matrix);

  keep = min(find((cumsum(explained) - this.threshold) > 0));
  if isempty(keep), keep = size(coeff, 1); end

  multiplier = diag(sqrt(latent(1:keep))) * coeff(:, 1:keep).';
end
