function [ indexes, levels, isAnisotropic ] = smolyakLevels( ...
  dimensionCount, level, anisotropy)

  isAnisotropic = nargin > 2 && ~isempty(anisotropy) && any(anisotropy ~= 1);
  if ~isAnisotropic
    [ indexes, levels ] = isotropic(dimensionCount, level);
  else
    assert(all(anisotropy > 0 & anisotropy <= 1));
    [ indexes, levels ] = anisotropic(dimensionCount, level, 1 ./ anisotropy);
  end
end

function [ indexes, levels ] = isotropic(dimensionCount, level)
  levels = max(0, level - dimensionCount + 1):level;
  indexes = cell(length(levels), 1);
  for i = 1:length(levels)
    indexes{i} = MultiIndex.smolyakLevel(dimensionCount, levels(i));
  end
end

function [ indexes, levels ] = anisotropic(dimensionCount, level, alpha)
  lowerBound = min(alpha) * level - sum(alpha);
  upperBound = min(alpha) * level;

  levels = 0:level;
  indexes = cell(level + 1, 1);
  for i = 1:(level + 1)
    indexes{i} = MultiIndex.smolyakLevel(dimensionCount, i - 1);
    level = sum(bsxfun(@times, double(indexes{i}), alpha), 2);
    indexes{i} = indexes{i}(lowerBound < level & level <= upperBound, :);
  end

  I = cellfun(@isempty, indexes);
  indexes(I) = [];
  levels(I) = [];
end
