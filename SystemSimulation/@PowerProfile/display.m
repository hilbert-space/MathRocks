function display(this)
  samplingInterval = this.samplingInterval;
  stepCount = size(this.values, 1);

  fprintf('Power profile:\n');
  fprintf('  Sampling interval: %.2e s\n', samplingInterval);
  fprintf('  Steps:             %d\n', stepCount);
  fprintf('  Duration:          %.2f s\n', stepCount * samplingInterval);
end
