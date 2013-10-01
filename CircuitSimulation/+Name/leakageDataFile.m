function name = leakageDataFile(varargin)
  options = Options(varargin{:});
  name = File.join(File.library('CircuitSimulation'), 'Circuits', ...
    [ String.join('_', 'data', options.referenceCircuit), '.txt' ]);
end