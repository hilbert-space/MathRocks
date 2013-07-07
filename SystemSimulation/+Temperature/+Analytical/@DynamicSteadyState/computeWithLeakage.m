function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});

  iterationLimit   = options.get('iterationLimit',   20);
  temperatureLimit = options.get('temperatureLimit', Utils.toKelvin(1e3));
  tolerance        = options.get('tolerance',        0.5);

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

  if ~options.has('L')
    L = leakage.Lnom * ones(processorCount, 1, stepCount);
  else
    assert(size(options.L, 1) == processorCount);
    L = repmat(options.L, [ 1, 1, stepCount ]);
  end

  sampleCount = size(L, 2);

  Pdyn = permute(repmat(Pdyn, [ 1, 1, sampleCount ]), [ 1 3 2 ]);

  T = Tamb * ones(processorCount, sampleCount, stepCount);
  P = zeros(processorCount, sampleCount, stepCount);

  Q = zeros(nodeCount, sampleCount, stepCount);
  W = zeros(nodeCount, sampleCount, stepCount);
  X = zeros(nodeCount, sampleCount, stepCount);

  Tlast = Tamb;
  I = 1:sampleCount;
  iterationCount = zeros(1, sampleCount);

  for i = 1:iterationLimit
    P(:, I, :) = Pdyn(:, I, :) + ...
      leakage.evaluate(L(:, I, :), T(:, I, :));

    Q(:, I, 1) = D * P(:, I, 1);
    W(:, I, 1) = Q(:, I, 1);

    for j = 2:stepCount
      Q(:, I, j) = D * P(:, I, j);
      W(:, I, j) = E * W(:, I, j - 1) + Q(:, I, j);
    end

    X(:, I, 1) = U * diag(1 ./ (1 - exp(dt * ...
      stepCount * Lambda))) * UT * W(:, I, stepCount);
    T(:, I, 1) = BT * X(:, I, 1) + Tamb;

    for j = 2:stepCount
      X(:, I, j) = E * X(:, I, j - 1) + Q(:, I, j - 1);
      T(:, I, j) = BT * X(:, I, j) + Tamb;
    end

    Tcurrent = permute(T(:, I, :), [ 1, 3, 2 ]);
    Tcurrent = reshape(Tcurrent, [], length(I));

    %
    % Thermal runaway
    %
    J = find(max(Tcurrent, [], 1) > temperatureLimit);
    iterationCount(I(J)) = Inf;

    %
    % Successful convergence
    %
    K = find(max(abs(Tcurrent - Tlast), [], 1) < tolerance);
    iterationCount(I(K)) = i;

    Tlast = Tcurrent;

    M = union(J, K);
    I(M) = [];
    Tlast(:, M) = [];

    if isempty(I), break; end
  end

  T = permute(T, [ 1, 3, 2 ]);
  output.P = permute(P, [ 1, 3, 2 ]);
  output.iterationCount = iterationCount;
end
