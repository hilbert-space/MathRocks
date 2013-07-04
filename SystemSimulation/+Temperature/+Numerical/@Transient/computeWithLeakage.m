function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});

  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  At = this.At;
  Bt = this.Bt;
  dt = this.samplingInterval;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;

  L = options.get('L', leakage.Lnom * ones(processorCount, 1));
  assert(size(L, 1) == processorCount);

  sampleCount = size(L, 2);

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  for i = 1:sampleCount
    T0 = Tamb * ones(1, this.nodeCount);

    for j = 1:stepCount
      [ ~, T0 ] = ode45(@(t, Tt) ...
        At * (Tt - Tamb) + ...
        Bt * (Pdyn(:, j) + leakage.evaluate(L, Tt(1:processorCount))), ...
        [ 0, dt ], T0);

      T0 = T0(end, :);

      T(:, j, i) = T0(1:processorCount);
      P(:, j, i) = Pdyn(:, j) + leakage.evaluate(L, T(:, j, i));
    end
  end

  output.P = P;
end
