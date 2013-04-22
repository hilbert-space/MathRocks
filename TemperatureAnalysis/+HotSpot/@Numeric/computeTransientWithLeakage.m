function [ T, stats ] = computeTransientWithLeakage(this, Pdyn, options);
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  At = this.At;
  Bt = this.Bt;
  dt = this.samplingInterval;
  Tamb = this.ambientTemperature;

  leak = options.leakage.evaluate;
  L = options.get('L', options.leakage.Lnom);

  T = zeros(processorCount, stepCount);
  Pleak = zeros(processorCount, stepCount);

  T0 = Tamb * ones(1, this.nodeCount);

  for i = 1:stepCount
    [ ~, T0 ] = ode45(@(t, Tt) ...
      At * (Tt - Tamb) + ...
      Bt * (Pdyn(:, i) + leak(L, Tt(1:processorCount))), ...
      [ 0, dt ], T0);

    T0 = T0(end, :);

    T(:, i) = T0(1:processorCount);
    Pleak(:, i) = leak(L, T(:, i));
  end

  stats.Pleak = Pleak;
end
