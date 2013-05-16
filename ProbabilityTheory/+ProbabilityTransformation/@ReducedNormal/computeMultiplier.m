function multiplier = computeMultiplier(this, C)
  multiplier = Utils.decomposeCorrelation(C, this.threshold)';
end
