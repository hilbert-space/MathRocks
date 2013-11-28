function crossComparison(varargin)
  options = Options(varargin{:});

  values = cellfun(@(value) value(:), options.values, 'UniformOutput', false);
  valueCount = length(values);

  data = NaN(valueCount, 1 + valueCount);

  for i = 1:valueCount
    data(i, 1) = mean(values{i});
    for j = 1:valueCount
      if i == j, continue; end
      data(i, 1 + j) = abs(mean((values{i} - values{j}) ./ values{i}));
    end
  end

  Print.table(options, 'rows', options.names, ...
    'columns', [ { 'Value' }, options.names ], 'values', data);
end