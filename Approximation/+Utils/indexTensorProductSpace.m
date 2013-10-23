function indexes = indexTensorProductSpace(dimensionCount, order)
  assert(order <= intmax('uint8'));
  indexes = Utils.tensor(repmat({ uint8(1:(order + 1)) }, 1, dimensionCount));
end
