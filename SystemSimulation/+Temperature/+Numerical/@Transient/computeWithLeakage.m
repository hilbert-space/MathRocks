function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});

  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  At = this.At;
  Bt = this.Bt;
  dt = this.samplingInterval;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;
  L = options.get('L', leakage.Lnom);

  if isscalar(L)
    L = L * ones(processorCount, 1);
  end

  T = zeros(processorCount, stepCount);
  Pleak = zeros(processorCount, stepCount);

  T0 = Tamb * ones(1, this.nodeCount);

  for i = 1:stepCount
    [ ~, T0 ] = ode45(@(t, Tt) ...
      At * (Tt - Tamb) + ...
      Bt * (Pdyn(:, i) + leakage.evaluate(L, Tt(1:processorCount))), ...
      [ 0, dt ], T0);

    T0 = T0(end, :);

    T(:, i) = T0(1:processorCount);
    Pleak(:, i) = leakage.evaluate(L, T(:, i));
  end

  output.Pleak = Pleak;
end
