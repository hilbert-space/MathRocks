function generateDumpParameterData(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);

  circuit = options.leakageOptions.circuit;
  display(circuit);

  parameterData = SPICE.generateParameterData(circuit, varargin{:});
  SPICE.dumpParameterData(circuit, parameterData, varargin{:});
end
