function indexes = indexTotalOrderSpace(dimensionCount, totalOrder)
  assert(totalOrder < intmax('uint8'));

  maximalIndexCount = nchoosek(dimensionCount + totalOrder, totalOrder);
  indexes = zeros(maximalIndexCount, dimensionCount, 'uint8');

  %
  % Level 0
  %
  if totalOrder == 0
    indexes = indexes + 1;
    return;
  end

  %
  % Level 1
  %
  indexes((1 + 1):(1 + dimensionCount), :) = eye(dimensionCount, 'uint8');
  if totalOrder == 1
    indexes = indexes + 1;
    return;
  end

  indexCount = 1 + dimensionCount;

  p = zeros(totalOrder, dimensionCount, 'uint32');
  p(1, :) = 1;

  for order = 2:totalOrder
    k = indexCount;
    for i = 1:dimensionCount
      p(order, i) = sum(p(order - 1, i:dimensionCount));
      for j = (k - p(order, i)):(k - 1)
        sequence = indexes(j + 1, :);
        sequence(i) = sequence(i) + 1;

        indexCount = indexCount + 1;
        indexes(indexCount, :) = sequence;
      end
    end
  end

  assert(maximalIndexCount == indexCount);
end
