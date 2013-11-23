function compute(varargin)
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options, ...
    'temperatureOptions', Options('analysis', 'DynamicSteadyState'));
  options = Configure.reliabilityAnalysis(options);

  temperature = Temperature(options.temperatureOptions);
  fatigue = Fatigue(options.fatigueOptions);

  T = temperature.compute(options.dynamicPower);

  [ expectation, output ] = fatigue.compute(T);

  fprintf('Mean time to failure: %.2f years\n', Utils.toYears(expectation));

  plot(fatigue, output);
end
