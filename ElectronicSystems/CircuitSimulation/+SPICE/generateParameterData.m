function data = generateParameterData(circuit, varargin)
  options = Options(varargin{:});

  pointCount = options.get('pointCount', 50);

  sweeps = cell(1, circuit.parameterCount);

  for i = 1:circuit.parameterCount
    range = circuit.parameterRanges{i};
    sweeps{i} = linspace(min(range), max(range), pointCount);
  end

  data = cell(1, circuit.parameterCount);
  [ data{:} ] = ndgrid(sweeps{:});
  data = cellfun(@(x) x(:), data, 'UniformOutput', false);
end
