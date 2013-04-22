function T = computeTransient(this, Pdyn, varargin)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;

  Q = D * Pdyn;
  X = Q(:, 1);

  T = zeros(processorCount, stepCount);
  T(:, 1) = BT * X + Tamb;

  for i = 2:stepCount
    X = E * X + Q(:, i);
    T(:, i) = BT * X + Tamb;
  end
end
