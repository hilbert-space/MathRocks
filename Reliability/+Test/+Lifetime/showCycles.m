function showCycles
  close all;
  setup;

  options = Configure.systemSimulation('processorCount', 2);
  Pdyn = options.dynamicPower;

  temperature = Temperature.Analytical.DynamicSteadyState(options.temperatureOptions);
  [ T, output ] = temperature.compute(Pdyn);

  Plot.powerTemperature(Pdyn, output.P - Pdyn, ...
    T, temperature.samplingInterval);

  lifetime = Lifetime('samplingInterval', options.samplingInterval);

  [ ~, output ] = lifetime.predict(T);

  Plot.thermalCycles(T, output);
  Plot.reliability(T, output);
end
