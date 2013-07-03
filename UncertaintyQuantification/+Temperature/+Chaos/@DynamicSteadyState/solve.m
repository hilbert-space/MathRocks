function [ T, output ] = solve(this, Pdyn, L, varargin)
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

  iterationLimit = options.get('iterationLimit', 10);
  temperatureLimit = options.get('temperatureLimit', Inf);
  tolerance = options.get('tolerance', 0.5);

  function T_ = computeOne(P_)
    W = zeros(nodeCount, stepCount);
    X = zeros(nodeCount, stepCount);

    Q = D * P_;

    W(:, 1) = Q(:, 1);

    for i = 2:stepCount
      W(:, i) = E * W(:, i - 1) + Q(:, i);
    end

    X(:, 1) = U * diag(1 ./ (1 - exp(dt * ...
      stepCount * Lambda))) * UT * W(:, stepCount);

    for i = 2:stepCount
      X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
    end

    T_ = BT * X + Tamb;
  end

  sampleCount = size(L, 2);

  T = zeros(processorCount * stepCount, sampleCount);
  P = zeros(processorCount * stepCount, sampleCount);
  iterationCount = zeros(1, sampleCount);

  %
  % NOTE: 'i' is already occupied!
  %
  for j = 1:sampleCount
    l = Utils.replicate(L(:, j), 1, stepCount);

    Pcurrent = Pdyn + leakage.evaluate(l, Tamb * ones(size(l)));
    Tcurrent = computeOne(Pcurrent);

    for k = 2:iterationLimit
      Tlast = Tcurrent;

      Pcurrent = Pdyn + leakage.evaluate(l, Tcurrent);
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

    T(:, j) = Tcurrent(:);
    P(:, j) = Pcurrent(:);
    iterationCount(j) = k;
  end

  output.P = P;
  output.iterationCount = iterationCount;
end
