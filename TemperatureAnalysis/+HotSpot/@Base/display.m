function display(this)
  fprintf('%s:\n', class(this));
  fprintf('  Processing elements: %d\n', this.processorCount);
  fprintf('  Thermal nodes:       %d\n', this.nodeCount);
  fprintf('  Sampling interval:   %.2e s\n', this.samplingInterval);
  fprintf('  Ambient temperature: %.2f C\n', ...
    Utils.toCelsius(this.ambientTemperature));
end
