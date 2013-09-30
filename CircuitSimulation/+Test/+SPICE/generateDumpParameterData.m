function generateDumpParameterData(varargin)
  setup;

  options = Options(varargin{:});

  filename = options.fetch('filename', []);

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);

  parameters = options.leakageParameters;
  parameterNames = fieldnames(parameters);

  if isempty(filename)
    filename = [ String.join('_', parameterNames), '.txt' ];
    filename = File.join('Circuits', filename);
  end
  fprintf('Parameter data filename: %s\n', filename);

  parameterData = SPICE.generateParameterData(parameters);
  SPICE.dumpParameterData(parameters, parameterData, filename);
end
