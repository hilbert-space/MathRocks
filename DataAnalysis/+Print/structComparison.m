function structComparison(varargin)
  options = Options(varargin{:});

  values = options.values;
  valueCount = length(values);

  fields = sort(fieldnames(values{1}));
  fieldCount = length(fields);

  exclude = options.get('exclude', @(varargin) true);

  names = cell(1, 2 * valueCount - 1);
  names{1} = options.names{1};
  for i = 2:valueCount
    names{1 + 2 * (i - 2) + 1} = options.names{i};
    names{1 + 2 * (i - 2) + 2} = 'Error, %';
  end

  I = [];
  data = zeros(0, 2 * valueCount - 1);
  for i = 1:fieldCount
    etalon = values{1}.(fields{i});

    if ~exclude(fields{i}, etalon), continue; end

    etalon = mean(etalon(:));
    data(i, 1) = etalon;

    for j = 2:valueCount
      value = values{j}.(fields{i});
      value = mean(value(:));
      error = 100 * abs((etalon - value) / etalon);
      data(i, 1 + 2 * (j - 2) + 1) = value;
      data(i, 1 + 2 * (j - 2) + 2) = error;
    end

    I = [ I, i ];
  end

  Print.table(options, 'rows', fields(I), ...
    'columns', names, 'values', data(I, :));
end
