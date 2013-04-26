function T = computeWithoutLeakage(this, Pdyn, options)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;

  Q = D * Pdyn;

  W = zeros(nodeCount, stepCount);
  W(:, 1) = Q(:, 1);

  for i = 2:stepCount
    W(:, i) = E * W(:, i - 1) + Q(:, i);
  end

  X = zeros(nodeCount, stepCount);
  X(:, 1) = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.UT * W(:, stepCount);

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
  end

  T = BT * X + Tamb;
end
