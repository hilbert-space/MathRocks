function [ T, output ] = solve(this, Pdyn, L, varargin)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;
  leakage = this.leakage;

  sampleCount = size(L, 2);

  T = zeros(processorCount * stepCount, sampleCount);
  P = zeros(processorCount * stepCount, sampleCount);

  P_ = bsxfun(@plus, Pdyn(:, 1), leakage.evaluate(L, Tamb * ones(size(L))));
  X_ = D * P_;
  T_ = BT * X_ + Tamb;

  range = 1:processorCount;
  T(range, :) = T_;
  P(range, :) = P_;

  for i = 2:stepCount
    P_ = bsxfun(@plus, Pdyn(:, i), leakage.evaluate(L, T_));
    X_ = E * X_ + D * P_;
    T_ = BT * X_ + Tamb;

    range = range + processorCount;
    T(range, :) = T_;
    P(range, :) = P_;
  end

  output.P = P;
end
