function [ T, output ] = computeWithoutLeakage(this, Pdyn, varargin)
  nodeCount = this.nodeCount;
  stepCount = size(Pdyn, 2);

  E = this.E;
  FP = this.F * Pdyn;
  W = FP(:, 1);

  for i = 2:stepCount
    W = E * W + FP(:, i);
  end

  X = zeros(nodeCount, stepCount);
  X(:, 1) = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.V * W;

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + FP(:, i - 1);
  end

  T = this.C * X + this.D * Pdyn + this.ambientTemperature;

  output = struct;
end
