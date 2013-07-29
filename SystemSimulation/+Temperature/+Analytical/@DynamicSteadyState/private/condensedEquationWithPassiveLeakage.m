function [ T, output ] = condensedEquationWithPassiveLeakage(this, Pdyn, options)
  iterationLimit   = options.get('iterationLimit',   this.iterationLimit);
  temperatureLimit = options.get('temperatureLimit', this.temperatureLimit);
  tolerance        = options.get('tolerance',        this.tolerance);

  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  E = this.E;
  F = this.F;

  Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.U';

  Tamb = this.Tamb;

  leakage = this.leakage;
  V = options.get('V', leakage.Vnom * ones(processorCount, 1));

  sampleCount = size(V, 2);

  iterationCount = zeros(1, sampleCount);

  X = zeros(nodeCount, stepCount);
  G = zeros(nodeCount, nodeCount, stepCount + 1);

  Q = F * Pdyn;
  W = Q(:, 1);

  G(:, :, 2) = eye(nodeCount);

  for i = 2:stepCount
    W = E * W + Q(:, i);
    G(:, :, i + 1) = E * G(:, :, i);
  end

  X(:, 1) = Z * W;

  G = cumsum(G, 3);
  W = Z * G(:, :, end);
  G(1:processorCount, 1:processorCount, 1) = C * W * F;

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
    W = E * W;
    G(1:processorCount, 1:processorCount, i) = C * (W + G(:, :, i)) * F;
  end

  X = C * X;
  G = G(1:processorCount, 1:processorCount, :);

  V = repmat(V, [ 1, 1, stepCount ]);
  T = Tamb * ones(processorCount, sampleCount, stepCount);

  Tlast = Tamb;
  I = 1:sampleCount;

  for i = 1:iterationLimit
    Pleak = leakage.compute(V(:, I, :), T(:, I, :));

    for j = 1:stepCount
      T(:, I, j) = bsxfun(@plus, X(:, j), ...
        G(:, :, j) * Pleak(:, :, j)) + Tamb;
    end

    Tcurrent = T(:, I, :);

    %
    % Thermal runaway
    %
    J = max(max(Tcurrent, [], 1), [], 3) > temperatureLimit;
    iterationCount(I(J)) = NaN;

    %
    % Successful convergence
    %
    K = max(max(abs(Tcurrent - Tlast), [], 1), [], 3) < tolerance;
    iterationCount(I(K)) = i;

    M = J | K;
    I(M) = [];

    if isempty(I), break; end

    Tlast = Tcurrent;
    Tlast(:, M, :) = [];
  end

  T = permute(T, [ 1, 3, 2 ]);
  T(:, :, isnan(iterationCount)) = NaN;

  output.iterationCount = iterationCount;
end
