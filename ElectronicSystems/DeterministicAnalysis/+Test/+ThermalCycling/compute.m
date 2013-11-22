function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);

  temperature = Temperature(options.temperatureOptions, ...
    'analysis', 'DynamicSteadyState');
  cycling = ThermalCycling('temperature', temperature);

  [ ~, output ] = cycling.compute(options.dynamicPower);
  plot(cycling, output, Utils.toCelsius( ...
    temperature.compute(options.dynamicPower)), ...
    'labels', { 'Time, s', 'Temperature, C' }, ...
    'timeLine', options.timeLine);
end
