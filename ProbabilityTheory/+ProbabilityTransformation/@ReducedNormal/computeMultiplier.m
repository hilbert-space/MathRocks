function multiplier = computeMultiplier(this, C, options)
  multiplier = Utils.decomposeCorrelation(C, options.threshold)';
end
