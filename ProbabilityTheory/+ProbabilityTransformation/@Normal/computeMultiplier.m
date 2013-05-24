function multiplier = computeMultiplier(this, C, options)
  threshold = options.get('threshold', 1);
  multiplier = Utils.decomposeCorrelation(C, threshold)';
end
