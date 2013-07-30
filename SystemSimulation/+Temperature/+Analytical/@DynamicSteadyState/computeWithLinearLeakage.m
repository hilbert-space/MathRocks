function [ T, output ] = condensedEquationWithLinearLeakage(this, Pdyn, options)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  E = this.E;
  F = this.F;

  V = options.get('V', ...
    this.leakage.Vnom * ones(processorCount, 1));
  Pleak = this.leakage.compute(V, 0);

  sampleCount = size(V, 2);

  X = zeros(nodeCount, stepCount);
  K = zeros(nodeCount, nodeCount, stepCount + 1);

  Q = F * Pdyn;
  W = Q(:, 1);

  K(:, :, 2) = eye(nodeCount);

  for i = 2:stepCount
    W = E * W + Q(:, i);
    K(:, :, i + 1) = E * K(:, :, i);
  end

  Z = this.U * diag(1 ./ (1 - exp(stepCount * ...
    this.samplingInterval * this.L))) * this.U';
  X(:, 1) = Z * W;

  K = cumsum(K, 3);
  W = Z * K(:, :, end);
  K(:, 1:processorCount, 1) = W * F;

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
    W = E * W;
    K(:, 1:processorCount, i) = (W + K(:, :, i)) * F;
  end

  T = zeros(processorCount, stepCount, sampleCount);
  for i = 1:stepCount
    T(:, i, :) = C * bsxfun(@plus, X(:, i), ...
      K(:, 1:processorCount, i) * Pleak);
  end

  T = T + this.Tamb;

  output = struct;
  output.iterationCount = ones(1, sampleCount);
end
