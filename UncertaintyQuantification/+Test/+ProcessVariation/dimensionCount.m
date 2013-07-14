function dimensionCount
  setup;

  sampleCount = 1e5;
  processorCount = [ 2 4 8 16 32 ];

  for i = 1:length(processorCount)
    options = configure('processorCount', processorCount(i));

    process = ProcessVariation.(options.processModel)(options.processOptions);

    fprintf('Processors: %d, Variables: %d\n', ...
      processorCount(i), process.dimensionCount);
    fprintf('%10s%20s%15s\n', 'Processor', 'Expectation, nm', 'Deviation, %');

    L = process.sample(sampleCount);
    expectation = mean(L, 1) * 1e9;
    deviation = sqrt(var(L, 0, 1)) * 1e9;

    for j = 1:processorCount(i)
      fprintf('%10d%20.2f%15.2f\n', j, expectation(j), ...
        deviation(j) / expectation(j) * 100);
    end

    fprintf('\n');
  end
end

function options = configure(varargin)
  options = Options(varargin{:});

  processorCount = options.getSet('processorCount', 4);

  options.die = Die('floorplan', File.join('..', 'SystemSimulation', ...
    '+Test', 'Assets', sprintf('%03d.flp', processorCount)));
  options.nominal = 45e-9;

  options = Configure.processVariation(options);
end
