function countDimensions(varargin)
  setup;

  processorCounts  = [2 4 8 16 32];

  fprintf('%15s%15s\n', 'Processors', 'Variables');
  for i = 1:length(processorCounts)
    options = Configure.systemSimulation( ...
      varargin{:}, 'processorCount', processorCounts(i));
    options = Configure.deterministicAnalysis(options);
    options = Configure.stochasticAnalysis(options);
    process = ProcessVariation(options.processOptions);
    fprintf('%15d%15d\n', processorCounts(i), sum(process.dimensions));
  end
end
