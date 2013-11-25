function indexesND = smolyakMethod(dimensionCount, level, anisotropy)
  if nargin < 3, anisotropy = []; end
  assert(all(anisotropy > 0 & anisotropy <= 1));

  indexesND = zeros(0, dimensionCount, 'uint8');

  indexes1D = cell(1, level + 1);
  for q = 0:level
    i = q + 1;
    indexes1D{i} = uint8(0:q);
  end

  for q = max(0, level - dimensionCount + 1):level
    %
    % Find all the indexes of the current level
    %
    indexes = MultiIndex.fixedDegree(dimensionCount, q); % zero based

    %
    % Account for the anisotropy
    %
    if ~isempty(anisotropy)
      indexes = indexes(round(sum(bsxfun(@rdivide, ...
        double(indexes), anisotropy), 2)) <= level, :);
    end

    %
    % Tensor the one-dimensional indexes
    %
    for i = 1:size(indexes, 1)
      indexesND = [ indexesND; Utils.tensor(indexes1D(indexes(i, :) + 1)) ];
    end
  end

  indexesND = unique(indexesND, 'rows', 'stable');
end
