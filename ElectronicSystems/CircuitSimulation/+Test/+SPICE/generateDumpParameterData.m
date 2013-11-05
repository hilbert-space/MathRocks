function generateDumpParameterData(varargin)
  setup;

  options = Options(varargin{:});

  filename = options.fetch('filename', []);

  options = Configure.systemSimulation(options);
  options = Configure.processVariation(options);

  parameters = options.leakageParameters;

  if isempty(filename)
    filename = Name.leakageParameterDataFile(options);
  end
  fprintf('Parameter data filename: %s\n', File.name(filename));

  parameterData = SPICE.generateParameterData(parameters);
  SPICE.dumpParameterData(parameters, parameterData, filename);
end
