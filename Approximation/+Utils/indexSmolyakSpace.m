function indexes = indexSmolyakSpace(dimensionCount, order)
  indexes = zeros(0, dimensionCount, 'uint8');

  minq = max(0, order - dimensionCount);
  maxq = order - 1;

  for q = minq:maxq
    indexes = [ indexes; Utils.indexSmolyakLevel(dimensionCount, q) ];
  end
end
