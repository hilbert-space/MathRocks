function parameterData = loadParameterData(parameters, filename)
  %
  % Loading
  %
  file = fopen(filename, 'r');

  initialized = false;
  maximalDataCount = 1e4;

  dimensionCount = NaN;
  data = NaN;
  units = NaN;

  i = 0;
  line = fgetl(file);
  while ischar(line)
    chunks = regexp(line, '\s+', 'split');
    line = fgetl(file);

    if ~initialized
      initialized = true;
      dimensionCount = length(chunks);
      data = zeros(maximalDataCount, dimensionCount);
      units = cell(1, dimensionCount);
    else
      assert(length(chunks) == dimensionCount);
    end

    i = i + 1;
    if i > maximalDataCount
      data = [ data; zeros(maximalDataCount, dimensionCount) ];
      maximalDataCount = 2 * maximalDataCount;
    end

    for j = 1:dimensionCount
      chunk = chunks{j};

      if isletter(chunk(end))
        unit = chunk(end);
        chunk = chunk(1:(end - 1));

        if ischar(units{j})
          assert(strcmp(units{j}, unit));
        else
          units{j} = unit;
        end
      end

      value = str2double(chunk);
      assert(~isempty(value));

      data(i, j) = value;
    end
  end

  fclose(file);

  data = data(1:i, :);

  %
  % Post-processing
  %
  names = fieldnames(parameters);
  assert(dimensionCount == length(names));

  parameterData = cell(1, dimensionCount);

  for i = 1:dimensionCount
    switch names{i}
    case 'T'
      parameterData{i} = Utils.toKelvin(data(:, i));
    otherwise
      parameterData{i} = data(:, i);
    end
    if isempty(units{i}), continue; end
    switch units{i}
    case 'n'
      parameterData{i} = parameterData{i} * 1e-9;
    otherwise
      assert(false);
    end
  end
end
