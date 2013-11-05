function dumpParameterData(parameters, parameterData, filename)
  %
  % Preprocessing
  %
  names = fieldnames(parameters);
  dimensionCount = length(names);

  units = cell(1, dimensionCount);

  for i = 1:dimensionCount
    switch names{i}
    case 'T'
      parameterData{i} = Utils.toCelsius(parameterData{i});
      units{i} = '';
    otherwise
      parameterData{i} = parameterData{i} * 1e9;
      units{i} = 'n';
    end
  end

  %
  % Dumping
  %
  file = fopen(filename, 'w');

  pointCount = length(parameterData{1});
  for i = 1:pointCount
    for j = 1:dimensionCount
      if j > 1, fprintf(file, '\t'); end
      fprintf(file, '%.2f%s', parameterData{j}(i), units{j});
    end
    fprintf(file, '\n');
  end

  fclose(file);
end
