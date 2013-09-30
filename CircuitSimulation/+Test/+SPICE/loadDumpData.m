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

  %
  % Loading
  %
  if isempty(targetDataFilename)
    targetDataFilename = 'ring_nangate.sw0';
    targetDataFilename = File.join('Circuits', targetDataFilename);
  end
  fprintf('Target data filename: %s\n', targetDataFilename);

  if isempty(parameterDataFilename)
    parameterDataFilename = [ String.join('_', parameterNames), '.txt' ];
    parameterDataFilename = File.join('Circuits', parameterDataFilename);
  end
  fprintf('Parameter data filename: %s\n', parameterDataFilename);

  targetData = SPICE.loadTargetData(targetName, targetDataFilename);
  parameterData = SPICE.loadParameterData(parameters, parameterDataFilename);
  assert(length(parameterData) == dimensionCount);

  %
  % Dumping
  %
  if isempty(outputFilename)
    outputFilename = [ String.join('_', 'leakage', parameterNames), '.txt' ];
    outputFilename = File.join('Circuits', outputFilename);
  end
  fprintf('Output filename: %s\n', outputFilename);

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
