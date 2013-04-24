function [ T, stats ] = computeDynamicSteadyStateWithLeakage(this, Pdyn, options)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  U = this.U;
  UT = this.UT;
  Lambda = this.L;

  Tamb = this.ambientTemperature;
  dt = this.samplingInterval;

  leak = options.leakage.evaluate;
  L = options.get('L', options.leakage.Lnom);

  iterationLimit = options.get('iterationLimit', 10);
  tolerance = options.get('tolerance', 0.5);

  W = zeros(nodeCount, stepCount);
  X = zeros(nodeCount, stepCount);

  function T = computeOne(P)
    Q = D * P;

    W(:, 1) = Q(:, 1);

    for i = 2:stepCount
      W(:, i) = E * W(:, i - 1) + Q(:, i);
    end

    X(:, 1) = U * diag(1 ./ (1 - exp(dt * ...
      stepCount * Lambda))) * UT * W(:, stepCount);

    for i = 2:stepCount
      X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
    end

    T = BT * X + Tamb;
  end

  i = 1;

  Pleak = leak(L, Tamb * ones(size(Pdyn)));
  T = computeOne(Pdyn + Pleak);

  for i = 2:iterationLimit
    Pleak = leak(L, T);
    Tnew = computeOne(Pdyn + Pleak);

    delta = max(abs(Tnew(:) - T(:)));
    T = Tnew;

    if delta < tolerance, break; end
  end

  stats.iterationCount = i;
  stats.Pleak = Pleak;
end
