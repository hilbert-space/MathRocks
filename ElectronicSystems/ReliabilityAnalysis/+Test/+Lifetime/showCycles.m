function showCycles(varargin)
  close all;
  setup;

  options = Configure.systemSimulation(varargin{:});
  options = Configure.deterministicAnalysis(options);
  Pdyn = options.dynamicPower;

  temperature = Temperature.Analytical.DynamicSteadyState(options);
  [ T, output ] = temperature.compute(Pdyn);

  Plot.powerTemperature(Pdyn, output.P - Pdyn, ...
    T, 'time', options.timeLine);

  lifetime = Lifetime('samplingInterval', options.samplingInterval);

  [ ~, output ] = lifetime.predict(T);

  Plot.thermalCycles(T, output);
  Plot.reliability(T, output);
end
