function display(this, powerProfile);
  stepCount = size(powerProfile, 2);

  fprintf('Power profile:\n');
  fprintf('  Sampling interval: %.2e s\n', this.samplingInterval);
  fprintf('  Steps:             %d\n', stepCount);
  fprintf('  Duration:          %.2f s\n', stepCount * this.samplingInterval);
end
