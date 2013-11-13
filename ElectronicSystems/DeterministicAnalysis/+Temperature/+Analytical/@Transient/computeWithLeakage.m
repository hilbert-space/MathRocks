function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  C = this.C;
  E = this.E;
  F = this.F;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;
  leak = leakage.evaluate;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  parameters{Tindex} = Tamb * ones(processorCount, sampleCount);
  P_ = bsxfun(@plus, Pdyn(:, 1), leak(parameters{:}));
  X_ = F * P_;
  T_ = C * X_ + Tamb;

  T(:, 1, :) = T_;
  P(:, 1, :) = P_;

  for i = 2:stepCount
    parameters{Tindex} = T_;
    P_ = bsxfun(@plus, Pdyn(:, i), leak(parameters{:}));
    X_ = E * X_ + F * P_;
    T_ = C * X_ + Tamb;

    T(:, i, :) = T_;
    P(:, i, :) = P_;
  end

  output.P = P;
end
