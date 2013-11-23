function [ index, fractions ] = countCycles(extrema)
  if isempty(extrema)
    index = zeros(2, 0, 'uint16');
    fractions = [];
    return;
  end

  extremumCount = length(extrema);
  cycleCount = 0;

  stack = zeros(1, extremumCount, 'uint16');
  index = zeros(2, extremumCount, 'uint16');
  fractions = zeros(1, extremumCount);

  function result = delta(i1, i2)
    result = abs(extrema(stack(i1)) - extrema(stack(i2)));
  end

  function append(i1, i2, cycle)
    cycleCount = cycleCount + 1;
    index(:, cycleCount) = stack([ i1, i2 ]);
    fractions(cycleCount) = cycle;
  end

  j = 0;
  for i = 1:extremumCount
    j = j + 1;
    stack(j) = i;

    while j > 2
      diff = delta(j - 2, j - 1);
      if diff > delta(j - 1, j), break; end

      if j == 3
        if diff > 0, append(j - 2, j - 1, 0.5); end
        stack([ j - 2, j - 1 ]) = stack([ j - 1, j ]);
        j = j - 1;
      else
        if diff > 0, append(j - 2, j - 1, 1); end
        stack(j - 2) = stack(j);
        j = j - 2;
      end
    end
  end

  for i = 1:(j - 1)
    if delta(i, i + 1) > 0, append(i, i + 1, 0.5); end
  end

  index = index(:, 1:cycleCount);
  fractions = fractions(1:cycleCount);
end
