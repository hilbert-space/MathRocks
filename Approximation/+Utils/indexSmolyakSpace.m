function indexes = indexSmolyakSpace(dimensionCount, level)
  %
  % See the notes in +Utils/smolyak.m.
  %

  indexes = zeros(0, dimensionCount, 'uint8');

  I = cell(1, level + 1);
  for q = 0:level
    i = q + 1;
    I{i} = uint8(0:q);
  end

  for q = max(0, level - dimensionCount + 1):level
    J = Utils.indexSmolyakLevel(dimensionCount, q) + 1;
    for i = 1:size(J, 1)
      indexes = [ indexes; Utils.tensor(I(J(i, :))) ];
    end
  end

  indexes = unique(indexes, 'rows', 'stable');
end
