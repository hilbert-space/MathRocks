function parameterData = generateParameterData(parameters)
  names = fieldnames(parameters);
  dimensionCount = length(names);

  sweeps = cell(1, dimensionCount);

  pointCount = 50;

  for i = 1:dimensionCount
    range = parameters.(names{i}).range;
    sweeps{i} = linspace(min(range), max(range), pointCount);
  end

  parameterData = cell(1, dimensionCount);
  [ parameterData{:} ] = ndgrid(sweeps{:});
  parameterData = cellfun(@(x) x(:), parameterData, 'UniformOutput', false);
end
