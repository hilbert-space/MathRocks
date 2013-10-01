function name = leakageTargetDataFile(varargin)
  options = Options(varargin{:});
  name = File.join('Circuits', [ lower(options.referenceCircuit), '.sw0' ]);
end
