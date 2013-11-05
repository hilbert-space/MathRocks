function [ T, output ] = computeWithoutLeakage(this, Pdyn, varargin)
  nodeCount = this.nodeCount;
  stepCount = size(Pdyn, 2);

  E = this.E;
  F = this.F;

  Q = F * Pdyn;
  W = Q(:, 1);

  for i = 2:stepCount
    W = E * W + Q(:, i);
  end

  X = zeros(nodeCount, stepCount);
  X(:, 1) = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.U' * W;

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
  end

  T = this.C * X + this.Tamb;

  output = struct;
end
