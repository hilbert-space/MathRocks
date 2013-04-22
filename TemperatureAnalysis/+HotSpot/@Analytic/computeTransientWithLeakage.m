function [ T, stats ] = computeTransientWithLeakage(this, Pdyn, options)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;

  leak = options.leakage.evaluate;
  L = options.get('L', options.leakage.Lnom);

  T = zeros(processorCount, stepCount);
  Pleak = zeros(processorCount, stepCount);

  Pleak(:, 1) = leak(L, Tamb);
  X = D * (Pdyn(:, 1) + Pleak(:, 1));
  T(:, 1) = BT * X + Tamb;

  for i = 2:stepCount
    Pleak(:, i) = leak(L, T(:, i - 1));
    X = E * X + D * (Pdyn(:, i) + Pleak(:, i));
    T(:, i) = BT * X + Tamb;
  end

  stats.Pleak = Pleak;
end
