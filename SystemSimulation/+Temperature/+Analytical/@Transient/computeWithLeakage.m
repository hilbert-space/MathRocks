function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});

  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;

  L = options.get('L', leakage.Lnom * ones(processorCount, 1));
  assert(size(L, 1) == processorCount);

  sampleCount = size(L, 2);

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  P_ = bsxfun(@plus, Pdyn(:, 1), leakage.evaluate(L, Tamb * ones(size(L))));
  X_ = D * P_;
  T_ = BT * X_ + Tamb;

  T(:, 1, :) = T_;
  P(:, 1, :) = P_;

  for i = 2:stepCount
    P_ = bsxfun(@plus, Pdyn(:, i), leakage.evaluate(L, T_));
    X_ = E * X_ + D * P_;
    T_ = BT * X_ + Tamb;

    T(:, i, :) = T_;
    P(:, i, :) = P_;
  end

  output.P = P;
end
