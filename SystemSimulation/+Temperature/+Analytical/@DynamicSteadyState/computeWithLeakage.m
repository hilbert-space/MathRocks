function [ Tcurrent, output ] = computeWithLeakage(this, Pdyn, varargin)
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
  L = options.get('L', leakage.Lnom);

  if isscalar(L)
    L = L * ones(size(Pdyn));
  else
    L = Utils.replicate(L(:), 1, stepCount);
  end

  iterationLimit = options.get('iterationLimit', 10);
  temperatureLimit = options.get('temperatureLimit', Inf);
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

  Pcurrent = Pdyn + leakage.evaluate(L, Tamb * ones(size(Pdyn)));
  Tcurrent = computeOne(Pcurrent);

  for k = 2:iterationLimit
    Tlast = Tcurrent;

    Pcurrent = Pdyn + leakage.evaluate(L, Tcurrent);
    Tcurrent = computeOne(Pcurrent);

    if max(max(Tcurrent)) > temperatureLimit
      %
      % Thermal runaway
      %
      k = iterationLimit;
      break;
    end

    if max(max(abs(Tcurrent - Tlast))) < tolerance
      %
      % Successful convergence
      %
      break;
    end
  end

  output.iterationCount = k;
  output.Pleak = Pcurrent - Pdyn;
end
