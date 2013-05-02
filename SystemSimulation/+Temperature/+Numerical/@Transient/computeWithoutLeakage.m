function T = computeWithoutLeakage(this, P, varargin)
  [ processorCount, stepCount ] = size(P);
  assert(processorCount == this.processorCount);

  At = this.At;
  Bt = this.Bt;
  dt = this.samplingInterval;
  Tamb = this.ambientTemperature;

  T = zeros(processorCount, stepCount);
  T0 = Tamb * ones(1, this.nodeCount);

  for i = 1:stepCount
    [ ~, T0 ] = ode45(@(t, Tt) ...
      At * (Tt - Tamb) + Bt * P(:, i), [ 0, dt ], T0);

    T0 = T0(end, :);
    T(:, i) = T0(1:processorCount);
  end
end
