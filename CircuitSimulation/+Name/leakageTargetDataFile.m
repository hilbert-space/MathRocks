function name = leakageTargetDataFile(varargin)
  options = Options(varargin{:});
  name = File.join('Circuits', [ options.referenceCircuit, '.sw0' ]);
end
