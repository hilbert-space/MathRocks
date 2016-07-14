function [T, output] = computeWithoutLeakage(this, Pdyn, varargin)
  stepCount = size(Pdyn, 2);

  X = zeros(this.nodeCount, stepCount);

  E = this.E;
  FP = this.F * Pdyn;

  X(:, 1) = FP(:, 1);
  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + FP(:, i);
  end

  T = this.C * X + this.D * Pdyn + this.ambientTemperature;

  output = struct;
end
