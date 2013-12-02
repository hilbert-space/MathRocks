function dumpParameterData(circuit, data, varargin)
  %
  % Preprocessing
  %
  for i = 1:circuit.parameterCount
    switch circuit.parameterNames{i}
    case 'T'
      data{i} = Utils.toCelsius(data{i});
    end
  end

  %
  % Dumping
  %
  file = fopen(circuit.parameterFilename, 'w');

  pointCount = length(data{1});
  for i = 1:pointCount
    for j = 1:circuit.parameterCount
      if j > 1, fprintf(file, '\t'); end
      fprintf(file, '%e', data{j}(i));
    end
    fprintf(file, '\n');
  end

  fclose(file);
end
