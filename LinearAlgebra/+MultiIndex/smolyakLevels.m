function [ indexes, levels ] = smolyakLevels(dimensionCount, level, anisotropy)
  if nargin < 3 || isempty(anisotropy)
    anisotropy = ones(1, dimensionCount);
  else
    assert(all(anisotropy > 0 & anisotropy <= 1));
  end

  alpha = 1 ./ anisotropy;
  lowerBound = min(alpha) * level - sum(alpha);
  upperBound = min(alpha) * level;

  levels = 0:level;
  indexes = cell(1 + level, 1);
  for i = 1:(level + 1)
    indexes{i} = MultiIndex.smolyakLevel(dimensionCount, i - 1);
    level = sum(bsxfun(@times, double(indexes{i}), alpha), 2);
    indexes{i} = indexes{i}(lowerBound < level & level <= upperBound, :);
  end

  I = cellfun(@isempty, indexes);
  indexes(I) = [];
  levels(I) = [];
end