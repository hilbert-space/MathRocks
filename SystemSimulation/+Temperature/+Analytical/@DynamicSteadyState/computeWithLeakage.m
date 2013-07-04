function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});

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

  leakage = this.leakage;

  L = options.get('L', leakage.Lnom * ones(processorCount, 1));
  assert(size(L, 1) == processorCount);

  iterationLimit = options.get('iterationLimit', 10);
  temperatureLimit = options.get('temperatureLimit', Inf);
  tolerance = options.get('tolerance', 0.5);

  W = zeros(nodeCount, stepCount);
  X = zeros(nodeCount, stepCount);

  function T_ = computeOne(P_)
    Q = D * P_;

    W(:, 1) = Q(:, 1);

    for k = 2:stepCount
      W(:, k) = E * W(:, k - 1) + Q(:, k);
    end

    X(:, 1) = U * diag(1 ./ (1 - exp(dt * ...
      stepCount * Lambda))) * UT * W(:, stepCount);

    for k = 2:stepCount
      X(:, k) = E * X(:, k - 1) + Q(:, k - 1);
    end

    T_ = BT * X + Tamb;
  end

  sampleCount = size(L, 2);

  T = zeros(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);
  iterationCount = zeros(1, sampleCount);

  for i = 1:sampleCount
    l = Utils.replicate(L(:, i), 1, stepCount);

    Pcurrent = Pdyn + leakage.evaluate(l, Tamb * ones(size(l)));
    Tcurrent = computeOne(Pcurrent);

    j = 1;
    while j < iterationLimit
      j = j + 1;

      Tlast = Tcurrent;

      Pcurrent = Pdyn + leakage.evaluate(l, Tcurrent);
      Tcurrent = computeOne(Pcurrent);

      if max(max(Tcurrent)) > temperatureLimit
        %
        % Thermal runaway
        %
        j = iterationLimit;
        break;
      end

      if max(max(abs(Tcurrent - Tlast))) < tolerance
        %
        % Successful convergence
        %
        break;
      end
    end

    T(:, :, i) = Tcurrent;
    P(:, :, i) = Pcurrent;
    iterationCount(i) = j;
  end

  output.P = P;
  output.iterationCount = iterationCount;
end
