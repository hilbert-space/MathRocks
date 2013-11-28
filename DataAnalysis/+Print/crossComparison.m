function crossComparison(varargin)
  options = Options(varargin{:});

  names = options.names;
  values = options.values;

  nameCount = length(names);

  [ nameFormat, valueFormat ] = format(options.names);

  fprintf(nameFormat, '');
  fprintf(nameFormat, options.get('name', 'Value'));
  fprintf(' | ');
  for i = 1:nameCount
    fprintf(nameFormat, names{i});
  end
  fprintf('\n');

  for i = 1:nameCount
    fprintf(nameFormat, names{i});
    fprintf(valueFormat, mean(values{i}));
    fprintf(' | ');
    for j = 1:nameCount
      if i == j
        fprintf(nameFormat, '-');
      else
        fprintf(valueFormat, abs(mean( ...
          (values{i} - values{j}) ./ values{i})));
      end
    end
    fprintf('\n');
  end
end