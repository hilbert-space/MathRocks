function detectThermalCycles(varargin)
  setup;

  options = Configure.systemSimulation('processorCount', 2, varargin{:});
  options = Configure.deterministicAnalysis('temperatureOptions', ...
    Options('analysis', 'DynamicSteadyState'), options);

  temperature = Temperature(options.temperatureOptions);
  T = temperature.compute(options.dynamicPower);

  [cycleIndex, cycleFractions, extremumIndex] = Utils.detectCycles(T, 2);

  Plot.extrema(Utils.toCelsius(T), extremumIndex, ...
    'labels', { 'Time, s', 'Temperature, C' }, ...
    'timeLine', options.timeLine);

  for i = 1:options.processorCount
    Plot.cycles(Utils.toCelsius(T(i, :)), ...
      cycleIndex{i}, cycleFractions{i}, ...
      'timeLine', options.timeLine);
  end
end
