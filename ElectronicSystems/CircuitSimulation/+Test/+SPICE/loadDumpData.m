function loadDumpData(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);

  circuit = options.leakageOptions.circuit;
  display(circuit);

  %
  % Loading
  %
  targetData = SPICE.loadTargetData(circuit, varargin{:});
  parameterData = SPICE.loadParameterData(circuit, varargin{:});

  assert(length(parameterData) == circuit.parameterCount);

  %
  % Dumping
  %
  file = fopen(circuit.dataFilename, 'w');

  fprintf(file, circuit.targetName);
  for i = 1:circuit.parameterCount
    fprintf(file, '\t%s', circuit.parameterNames{i});
  end
  fprintf(file, '\n');

  for i = 1:length(targetData)
    fprintf(file, '%e', targetData(i));
    for j = 1:circuit.parameterCount
      fprintf(file, '\t%e', parameterData{j}(i));
    end
    fprintf(file, '\n');
  end

  fclose(file);
end
