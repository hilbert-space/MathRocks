function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  At = this.At;
  Bt = this.Bt;
  dt = this.samplingInterval;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;
  leak = leakage.compute;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  function Tt = target(k, Tt)
    parameters{Tindex} = Tt(1:processorCount);
    Tt = At * (Tt - Tamb) + Bt * (Pdyn(:, k) + leak(parameters{:}));
  end

  for i = 1:sampleCount
    T0 = Tamb * ones(1, this.nodeCount);

    for j = 1:stepCount
      [ ~, T0 ] = ode45(@(t, Tt) target(j, Tt), [ 0, dt ], T0);

      T0 = T0(end, :);

      T(:, j, i) = T0(1:processorCount);
      parameters{Tindex} = T(:, j, i);
      P(:, j, i) = Pdyn(:, j) + leak(parameters{:});
    end
  end

  output.P = P;
end
