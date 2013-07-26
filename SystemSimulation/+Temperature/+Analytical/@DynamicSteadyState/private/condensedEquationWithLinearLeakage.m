function [ T, output ] = condensedEquationWithLinearLeakage(this, Pdyn, options)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  E = this.E;
  F = this.F;

  Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.U';

  Tamb = this.Tamb;

  leakage = this.leakage;
  V = options.get('V', leakage.Vnom * ones(processorCount, 1));

  sampleCount = size(V, 2);

  V = repmat(V, [ 1, 1, stepCount ]);
  Pdyn = permute(repmat(Pdyn, [ 1, 1, sampleCount ]), [ 1 3 2 ]);

  T = Tamb * ones(processorCount, sampleCount, stepCount);
  P = zeros(processorCount, sampleCount, stepCount);

  Q = zeros(nodeCount, sampleCount, stepCount);

  P = Pdyn + leakage.compute(V, T);

  Q(:, :, 1) = F * P(:, :, 1);
  W = Q(:, :, 1);
  for j = 2:stepCount
    Q(:, :, j) = F * P(:, :, j);
    W = E * W + Q(:, :, j);
  end

  X = Z * W;
  T(:, :, 1) = C * X + Tamb;
  for j = 2:stepCount
    X = E * X + Q(:, :, j - 1);
    T(:, :, j) = C * X + Tamb;
  end

  T = permute(T, [ 1, 3, 2 ]);
  P = permute(P, [ 1, 3, 2 ]);

  output.P = P;
end
