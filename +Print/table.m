function table(varargin)
  options = Options(varargin{:});

  rows = options.rows;
  columns = options.columns;
  values = options.values;

  rowCount = length(rows);

  if options.get('capitalize', true)
    rows = cellfun(@String.capitalize, rows, 'UniformOutput', false);
    columns = cellfun(@String.capitalize, columns, 'UniformOutput', false);
  end

  [columnFormat, valueFormat] = format(columns);
  rowFormat = format(rows);

  fprintf(rowFormat, '');
  fprintf(columnFormat, columns{:});
  fprintf('\n');

  for i = 1:rowCount
    fprintf(rowFormat, rows{i});
    fprintf(valueFormat, values(i, :));
    fprintf('\n');
  end
end
