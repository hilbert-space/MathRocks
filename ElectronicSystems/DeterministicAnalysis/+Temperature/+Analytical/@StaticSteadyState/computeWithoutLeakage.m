function [T, output] = computeWithoutLeakage(this, Pdyn, varargin)
  stepCount = size(Pdyn, 2);
  if stepCount > 1, Pdyn = mean(Pdyn, 2); end

  T = this.R * Pdyn + this.ambientTemperature;

  output = struct;
  output.P = Pdyn;
end
