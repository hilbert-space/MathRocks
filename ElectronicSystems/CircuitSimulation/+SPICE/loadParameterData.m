function data = loadParameterData(circuit, varargin)
  %
  % Loading
  %
  file = fopen(circuit.parameterFilename, 'r');

  initialized = false;
  maximalDataCount = 1e4;

  parameterCount = NaN;
  buffer = NaN;

  i = 0;
  line = fgetl(file);
  while ischar(line)
    chunks = regexp(line, '\s+', 'split');
    line = fgetl(file);

    if ~initialized
      initialized = true;
      parameterCount = length(chunks);
      buffer = zeros(maximalDataCount, parameterCount);
    else
      assert(length(chunks) == parameterCount);
    end

    i = i + 1;
    if i > maximalDataCount
      buffer = [buffer; zeros(maximalDataCount, parameterCount)];
      maximalDataCount = 2 * maximalDataCount;
    end

    for j = 1:parameterCount
      value = str2double(chunks{j});
      assert(~isempty(value));
      buffer(i, j) = value;
    end
  end

  fclose(file);

  buffer = buffer(1:i, :);

  %
  % Post-processing
  %
  assert(parameterCount == circuit.parameterCount);

  data = cell(1, circuit.parameterCount);

  for i = 1:circuit.parameterCount
    switch circuit.parameterNames{i}
    case 'T'
      data{i} = Utils.toKelvin(buffer(:, i));
    otherwise
      data{i} = buffer(:, i);
    end
  end
end
