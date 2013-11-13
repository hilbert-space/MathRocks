function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  if isa(this.leakage, 'LeakagePower.Linear')
    [ T, output ] = computeWithLinearLeakage(this, Pdyn, varargin{:});
  else
    [ T, output ] = computeWithNonlinearLeakage(this, Pdyn, varargin{:});
  end
end

function [ T, output ] = computeWithNonlinearLeakage(this, Pdyn, varargin)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  E = this.E;
  F = this.F;
  Tamb = this.ambientTemperature;
  iterationLimit = this.iterationLimit;
  temperatureLimit = this.temperatureLimit;
  convergenceTolerance = this.convergenceTolerance;

  Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.U';

  leakage = this.leakage;
  leak = leakage.evaluate;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  param = cell(1, leakage.parameterCount);
  Pindex = setdiff(1:leakage.parameterCount, Tindex);

  iterationCount = zeros(1, sampleCount);

  switch this.algorithm
  case 1 % Slower but more memory efficient
    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    X = zeros(nodeCount, stepCount);

    for i = 1:sampleCount
      for j = Pindex
        param{j} = repmat( ...
          parameters{j}(:, i), [ 1, stepCount ]);
      end

      Tlast = Tamb;

      for j = 1:iterationLimit
        param{Tindex} = T(:, :, i);

        P(:, :, i) = Pdyn + leak(param{:});

        Q = F * P(:, :, i);
        W = Q(:, 1);
        for k = 2:stepCount
          W = E * W + Q(:, k);
        end

        X(:, 1) = Z * W;
        for k = 2:stepCount
          X(:, k) = E * X(:, k - 1) + Q(:, k - 1);
        end

        Tcurrent = C * X + Tamb;
        T(:, :, i) = Tcurrent;

        if max(max(Tcurrent)) > temperatureLimit
          %
          % Thermal runaway
          %
          j = NaN;
          break;
       end

        if max(max(abs(Tcurrent - Tlast))) < convergenceTolerance
          %
          % Successful convergence
          %
          break;
        end

        Tlast = Tcurrent;
      end

      iterationCount(i) = j;
    end
  case 2 % Faster but less memory efficient
    for i = Pindex
      parameters{i} = repmat( ...
        parameters{i}, [ 1, 1, stepCount ]);
    end

    Pdyn = permute(repmat(Pdyn, [ 1, 1, sampleCount ]), [ 1 3 2 ]);

    T = Tamb * ones(processorCount, sampleCount, stepCount);
    P = zeros(processorCount, sampleCount, stepCount);

    Q = zeros(nodeCount, sampleCount, stepCount);

    Tlast = Tamb;
    I = 1:sampleCount;

    for i = 1:iterationLimit
      for j = Pindex
        param{j} = parameters{j}(:, I, :);
      end
      param{Tindex} = T(:, I, :);

      P(:, I, :) = Pdyn(:, I, :) + leak(param{:});

      Q(:, I, 1) = F * P(:, I, 1);
      W = Q(:, I, 1);
      for j = 2:stepCount
        Q(:, I, j) = F * P(:, I, j);
        W = E * W + Q(:, I, j);
      end

      X = Z * W;
      T(:, I, 1) = C * X + Tamb;
      for j = 2:stepCount
        X = E * X + Q(:, I, j - 1);
        T(:, I, j) = C * X + Tamb;
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
      K = max(max(abs(Tcurrent - Tlast), [], 1), [], 3) < convergenceTolerance;
      iterationCount(I(K)) = i;

      M = J | K;
      I(M) = [];

      if isempty(I), break; end

      Tlast = Tcurrent;
      Tlast(:, M, :) = [];
    end

    T = permute(T, [ 1, 3, 2 ]);
    P = permute(P, [ 1, 3, 2 ]);
  case 3 % A fast and memory-efficient approximation
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

    G = G(1:processorCount, 1:processorCount, :);

    Tdyn = permute(repmat(C * X + Tamb, [ 1, 1, sampleCount ]), [ 1, 3, 2 ]);

    T = Tdyn;

    I = 1:sampleCount;

    for i = 1:iterationLimit
      for j = Pindex
        param{j} = parameters{j}(:, I);
      end

      Tlast = T(:, I, :);

      for j = 1:stepCount
        param{Tindex} = T(:, I, j);
        T(:, I, j) = Tdyn(:, I, j) + ...
          G(:, :, j) * leak(param{:});
      end

      %
      % Thermal runaway
      %
      J = max(max(T(:, I, :), [], 1), [], 3) > temperatureLimit;
      iterationCount(I(J)) = NaN;

      %
      % Successful convergence
      %
      K = max(max(abs(T(:, I, :) - Tlast), [], 1), [], 3) < convergenceTolerance;
      iterationCount(I(K)) = i;

      M = J | K;
      I(M) = [];

      if isempty(I), break; end
    end

    T = permute(T, [ 1, 3, 2 ]);
  otherwise
    assert(false);
  end

  I = isnan(iterationCount);
  T(:, :, I) = NaN;
  P(:, :, I) = NaN;

  output.P = P;
  output.iterationCount = iterationCount;
end

function [ T, output ] = computeWithLinearLeakage(this, Pdyn, varargin)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  E = this.E;
  F = this.F;

  leakage = this.leakage;
  leak = leakage.evaluate;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  parameters{Tindex} = 0;
  Pleak = leak(parameters{:});

  X = zeros(nodeCount, stepCount);
  K = zeros(nodeCount, nodeCount, stepCount + 1);

  Q = F * Pdyn;
  W = Q(:, 1);

  K(:, :, 2) = eye(nodeCount);

  for i = 2:stepCount
    W = E * W + Q(:, i);
    K(:, :, i + 1) = E * K(:, :, i);
  end

  Z = this.U * diag(1 ./ (1 - exp(stepCount * ...
    this.samplingInterval * this.L))) * this.U';
  X(:, 1) = Z * W;

  K = cumsum(K, 3);
  W = Z * K(:, :, end);
  K(:, 1:processorCount, 1) = W * F;

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
    W = E * W;
    K(:, 1:processorCount, i) = (W + K(:, :, i)) * F;
  end

  T = zeros(processorCount, stepCount, sampleCount);
  for i = 1:stepCount
    T(:, i, :) = C * bsxfun(@plus, X(:, i), ...
      K(:, 1:processorCount, i) * Pleak);
  end

  T = T + this.ambientTemperature;

  output = struct;
  output.iterationCount = ones(1, sampleCount);
end
