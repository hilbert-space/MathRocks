function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});
  [ T, output ] = feval( ...
    options.get('algorithm', 'condensedEquation'), this, Pdyn, options);
end

function [ T, output ] = condensedEquation(this, Pdyn, options)
  iterationLimit   = options.get('iterationLimit', 20);
  temperatureLimit = options.get('temperatureLimit', Utils.toKelvin(1e3));
  tolerance        = options.get('tolerance', 0.5);

  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

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

  sampleCount = size(L, 2);

  iterationCount = zeros(1, sampleCount);

  function Version1
    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    W = zeros(nodeCount, stepCount);
    X = zeros(nodeCount, stepCount);

    for i = 1:sampleCount
      l = Utils.replicate(L(:, i), 1, stepCount);

      Tlast = Tamb;

      for j = 1:iterationLimit
        P(:, :, i) = Pdyn + leakage.evaluate(l, T(:, :, i));

        Q = D * P(:, :, i);
        W(:, 1) = Q(:, 1);

        for k = 2:stepCount
          W(:, k) = E * W(:, k - 1) + Q(:, k);
        end

        X(:, 1) = U * diag(1 ./ (1 - exp(dt * ...
          stepCount * Lambda))) * UT * W(:, stepCount);

        for k = 2:stepCount
          X(:, k) = E * X(:, k - 1) + Q(:, k - 1);
        end

        Tcurrent = BT * X + Tamb;
        T(:, :, i) = Tcurrent;

        if max(max(Tcurrent)) > temperatureLimit
          %
          % Thermal runaway
          %
          j = Inf;
          break;
        end

        if max(max(abs(Tcurrent - Tlast))) < tolerance
          %
          % Successful convergence
          %
          break;
        end

        Tlast = Tcurrent;
      end

      iterationCount(i) = j;
    end

    output.P = P;
  end

  function Version2
    L = repmat(options.L, [ 1, 1, stepCount ]);

    Pdyn = permute(repmat(Pdyn, [ 1, 1, sampleCount ]), [ 1 3 2 ]);

    T = Tamb * ones(processorCount, sampleCount, stepCount);
    P = zeros(processorCount, sampleCount, stepCount);

    Q = zeros(nodeCount, sampleCount, stepCount);
    W = zeros(nodeCount, sampleCount, stepCount);
    X = zeros(nodeCount, sampleCount, stepCount);

    Tlast = Tamb;
    I = 1:sampleCount;

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

      Tcurrent = T(:, I, :);

      %
      % Thermal runaway
      %
      J = find(max(max(Tcurrent, [], 1), [], 3) > temperatureLimit);
      iterationCount(I(J)) = Inf;

      %
      % Successful convergence
      %
      K = find(max(max(abs(Tcurrent - Tlast), [], 1), [], 3) < tolerance);
      iterationCount(I(K)) = i;

      M = union(J, K);
      I(M) = [];

      if isempty(I), break; end

      Tlast = Tcurrent;
      Tlast(:, M, :) = [];
    end

    T = permute(T, [ 1, 3, 2 ]);
    output.P = permute(P, [ 1, 3, 2 ]);
  end

  eval([ 'Version', num2str(options.get('version', 1)) ]);

  output.iterationCount = iterationCount;
end

function [ T, output ] = blockCirculant(this, Pdyn, options)
  iterationLimit   = options.get('iterationLimit', 20);
  temperatureLimit = options.get('temperatureLimit', Utils.toKelvin(1e3));
  tolerance        = options.get('tolerance', 0.5);

  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;
  L = options.get('L', leakage.Lnom * ones(processorCount, 1));

  sampleCount = size(L, 2);

  A = cat(3, this.E, -eye(nodeCount));
  A = conj(fft(A, stepCount, 3));

  LU = cell(stepCount, 2);
  for i = 1:stepCount
    [ LU{i, 1}, LU{i, 2} ] = lu(A(:, :, i));
  end

  T = Tamb * ones(processorCount, stepCount, sampleCount);
  P = zeros(processorCount, stepCount, sampleCount);

  X = zeros(nodeCount, stepCount);

  for i = 1:sampleCount
    l = Utils.replicate(L(:, i), 1, stepCount);

    Tlast = Tamb;

    for j = 1:iterationLimit
      P(:, :, i) = Pdyn + leakage.evaluate(l, T(:, :, i));

      B = fft(-D * P(:, :, i), stepCount, 2);

      for k = 1:stepCount
        X(:, k) = LU{k, 2} \ (LU{k, 1} \ B(:, k));
      end

      Tcurrent = BT * ifft(X, stepCount, 2) + Tamb;
      T(:, :, i) = Tcurrent;

      if max(max(Tcurrent)) > temperatureLimit
        %
        % Thermal runaway
        %
        j = Inf;
        break;
      end

      if max(max(abs(Tcurrent - Tlast))) < tolerance
        %
        % Successful convergence
        %
        break;
      end

      Tlast = Tcurrent;
    end

    iterationCount(i) = j;
  end

  output.P = P;
  output.iterationCount = iterationCount;
end
