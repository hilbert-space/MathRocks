function parameterData = generateParameterData(parameters)
  names = fieldnames(parameters);
  dimensionCount = length(names);

  sweeps = cell(1, dimensionCount);

  pointCount = 50;

  for i = 1:dimensionCount
    parameter = parameters.(names{i});

    if parameter.has('range')
      range = parameter.range;
    elseif parameter.has('nominal') && parameter.has('variance')
      deviation = sqrt(parameter.variance);
      range = [ ...
        parameter.nominal - 5 * deviation, ...
        parameter.nominal + 5 * deviation ];
    else
      assert(false);
    end

    sweeps{i} = linspace(min(range), max(range), pointCount);
  end

  parameterData = cell(1, dimensionCount);
  [ parameterData{:} ] = ndgrid(sweeps{:});
  parameterData = cellfun(@(x) x(:), parameterData, 'UniformOutput', false);
end
