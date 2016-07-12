function indexes = tensorProductSpace(dimensionCount, order)
  assert(order <= intmax('uint8'));
  indexes = Utils.tensor(repmat({ uint8(0:order) }, 1, dimensionCount));
end
