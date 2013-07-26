function [ T, output ] = computeWithLeakage(this, Pdyn, options)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  C = this.C;
  E = this.E;
  F = this.F;
  Tamb = this.Tamb;

  leakage = this.leakage;

  V = options.get('V', leakage.Vnom * ones(processorCount, 1));
  assert(size(V, 1) == processorCount);

  sampleCount = size(V, 2);

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  P_ = bsxfun(@plus, Pdyn(:, 1), leakage.compute(V, Tamb * ones(size(V))));
  X_ = F * P_;
  T_ = C * X_ + Tamb;

  T(:, 1, :) = T_;
  P(:, 1, :) = P_;

  for i = 2:stepCount
    P_ = bsxfun(@plus, Pdyn(:, i), leakage.compute(V, T_));
    X_ = E * X_ + F * P_;
    T_ = C * X_ + Tamb;

    T(:, i, :) = T_;
    P(:, i, :) = P_;
  end

  output.P = P;
end
