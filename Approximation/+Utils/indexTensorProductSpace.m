function indexes = indexTensorProductSpace(dimensionCount, level)
  assert(level <= intmax('uint8'));
  indexes = Utils.tensor(repmat({ uint8(0:level) }, 1, dimensionCount));
end
