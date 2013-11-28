function structComparison(varargin)
  options = Options(varargin{:});

  names = options.names;
  values = options.values;
  exclude = options.get('exclude', @(varargin) true);

  fields = sort(fieldnames(values{1}));

  nameCount = length(names);
  fieldCount = length(fields);

  [ nameFormat, valueFormat ] = format(names);
  fieldFormat = format(fields);

  fprintf(fieldFormat, '');
  fprintf(nameFormat, names{1});
  fprintf(' | ');
  for i = 2:nameCount
    fprintf(nameFormat, names{i});
    fprintf(nameFormat, 'Error, %');
  end
  fprintf('\n');

  for i = 1:fieldCount
    etalon = values{1}.(fields{i}); 
    if ~exclude(fields{i}, etalon), continue; end

    fprintf(fieldFormat, String.capitalize(fields{i}));

    etalon = mean(etalon(:));
    fprintf(valueFormat, etalon);
    fprintf(' | ');

    for j = 2:nameCount
      value = values{j}.(fields{i});
      value = mean(value(:));
      fprintf(valueFormat, value);
      fprintf(nameFormat, sprintf('%.4f', ...
        100 * abs((etalon - value) / etalon)));
    end
    fprintf('\n');
  end
end