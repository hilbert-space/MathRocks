function indexes = tensorProduct(dimensionCount, degree)
  assert(degree <= intmax('uint8'));
  indexes = Utils.tensor(repmat({ uint8(0:degree) }, 1, dimensionCount));
end
