function [ T, output ] = solve(this, Pdyn, options)
  if isempty(options.get('leakage', this.leakage))
    T = computeWithoutLeakage(this, Pdyn);
    output = struct;
  else
    [ T, output ] = computeWithLeakage(this, Pdyn, options);
  end
end

function T = computeWithoutLeakage(this, Pdyn)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  C = this.C;
  E = this.E;
  F = this.F;
  Tamb = this.ambientTemperature;

  Q = F * Pdyn;
  X = Q(:, 1);

  T = zeros(processorCount, stepCount);
  T(:, 1) = C * X + Tamb;

  for i = 2:stepCount
    X = E * X + Q(:, i);
    T(:, i) = C * X + Tamb;
  end
end

function [ T, output ] = computeWithLeakage(this, Pdyn, options)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  C = this.C;
  E = this.E;
  F = this.F;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;

  L = options.get('L', leakage.Lnom * ones(processorCount, 1));
  assert(size(L, 1) == processorCount);

  sampleCount = size(L, 2);

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  P_ = bsxfun(@plus, Pdyn(:, 1), leakage.compute(L, Tamb * ones(size(L))));
  X_ = F * P_;
  T_ = C * X_ + Tamb;

  T(:, 1, :) = T_;
  P(:, 1, :) = P_;

  for i = 2:stepCount
    P_ = bsxfun(@plus, Pdyn(:, i), leakage.compute(L, T_));
    X_ = E * X_ + F * P_;
    T_ = C * X_ + Tamb;

    T(:, i, :) = T_;
    P(:, i, :) = P_;
  end

  output.P = P;
end
