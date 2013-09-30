function loadDumpData(varargin)
  setup;

  options = Options(varargin{:});

  targetName = options.fetch('targetName', 'Ileak');
  targetDataFilename = options.fetch('targetDataFilename', []);
  parameterDataFilename = options.fetch('parameterDataFilename', []);
  outputFilename = options.fetch('outputFilename', []);

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);

  parameters = options.leakageParameters;
  parameterNames = fieldnames(parameters);
  dimensionCount = length(parameterNames);

  referenceCircuit = options.referenceCircuit;

  %
  % Loading
  %
  if isempty(targetDataFilename)
    targetDataFilename = Name.leakageTargetDataFile(options);
  end
  fprintf('Target data filename: %s\n', File.name(targetDataFilename));

  if isempty(parameterDataFilename)
    parameterDataFilename = Name.leakageParameterDataFile(options);
  end
  fprintf('Parameter data filename: %s\n', File.name(parameterDataFilename));

  targetData = SPICE.loadTargetData(targetName, targetDataFilename);
  parameterData = SPICE.loadParameterData(parameters, parameterDataFilename);
  assert(length(parameterData) == dimensionCount);

  %
  % Dumping
  %
  if isempty(outputFilename)
    outputFilename = Name.leakageDataFile(options);
  end
  fprintf('Output filename: %s\n', File.name(outputFilename));

  file = fopen(outputFilename, 'w');

  fprintf(file, targetName);
  for i = 1:dimensionCount
    fprintf(file, '\t%s', parameterNames{i});
  end
  fprintf(file, '\n');

  for i = 1:length(targetData)
    fprintf(file, '%e', targetData(i));
    for j = 1:dimensionCount
      fprintf(file, '\t%e', parameterData{j}(i));
    end
    fprintf(file, '\n');
  end

  fclose(file);
end
