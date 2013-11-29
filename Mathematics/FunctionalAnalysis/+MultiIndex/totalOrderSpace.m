function indexes = totalOrderSpace(dimensionCount, order)
  assert(order < intmax('uint8'));

  maximalIndexCount = nchoosek(dimensionCount + order, order);
  indexes = zeros(maximalIndexCount, dimensionCount, 'uint8');

  %
  % Level 0
  %
  if order == 0, return; end

  %
  % Level 1
  %
  indexes((1 + 1):(1 + dimensionCount), :) = eye(dimensionCount, 'uint8');
  if order == 1, return; end

  indexCount = 1 + dimensionCount;

  p = zeros(order, dimensionCount, 'uint32');
  p(1, :) = 1;

  for q = 2:order
    k = indexCount;
    for i = 1:dimensionCount
      p(q, i) = sum(p(q - 1, i:dimensionCount));
      for j = (k - p(q, i)):(k - 1)
        sequence = indexes(j + 1, :);
        sequence(i) = sequence(i) + 1;

        indexCount = indexCount + 1;
        indexes(indexCount, :) = sequence;
      end
    end
  end

  assert(maximalIndexCount == indexCount);
end
