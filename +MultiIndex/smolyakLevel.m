function indexes = smolyakLevel(dimensionCount, level)
  assert(dimensionCount + level <= intmax('uint8'));

  maximalIndexCount = 10 * dimensionCount;
  indexes = zeros(maximalIndexCount, dimensionCount, 'uint8');

  sequence = zeros(1, dimensionCount, 'uint8');
  sequence(1) = level;

  indexes(1, :) = sequence;
  indexCount = 1;

  c = 1;
  while sequence(dimensionCount) < level
    if c == dimensionCount
      for i = (c - 1):-1:1
        c = i;
        if sequence(i) ~= 0, break; end
      end
    end

    sequence(c) = sequence(c) - 1;
    c = c + 1;
    sequence(c) = level - sum(sequence(1:(c - 1)));

    if c < dimensionCount
      sequence((c + 1):dimensionCount) = ...
        zeros(1, dimensionCount - c, 'uint8');
    end

    indexCount = indexCount + 1;

    if indexCount > maximalIndexCount
      indexes = [indexes; zeros(maximalIndexCount, ...
        dimensionCount, 'uint8')];
      maximalIndexCount = 2 * maximalIndexCount;
    end

    indexes(indexCount, :) = sequence;
  end

  indexes = indexes(1:indexCount, :);
end
