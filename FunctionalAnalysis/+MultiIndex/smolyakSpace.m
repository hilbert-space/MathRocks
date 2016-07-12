function indexesND = smolyakSpace(dimensionCount, level, varargin)
  [indexes, levels] =  MultiIndex.smolyakLevels( ...
    dimensionCount, level, varargin{:});

  maximalLevel = max(levels);

  indexes1D = cell(1, maximalLevel + 1);
  for i = 1:(maximalLevel + 1)
    indexes1D{i} = uint8(0:(i - 1));
  end

  indexesND = zeros(0, dimensionCount, 'uint8');
  for i = 1:length(indexes)
    %
    % Tensor the one-dimensional indexes
    %
    for j = 1:size(indexes{i}, 1)
      index = indexes{i}(j, :);
      indexesND = [indexesND; Utils.tensor(indexes1D(index + 1))];
    end
  end

  indexesND = unique(indexesND, 'rows', 'stable');
end
