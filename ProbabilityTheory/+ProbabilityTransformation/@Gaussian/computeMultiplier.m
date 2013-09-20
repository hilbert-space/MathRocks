function multiplier = computeMultiplier(~, C, options)
  reductionThreshold = options.get('reductionThreshold', 1);
  multiplier = Utils.decomposeCorrelation(C, reductionThreshold)';
end
