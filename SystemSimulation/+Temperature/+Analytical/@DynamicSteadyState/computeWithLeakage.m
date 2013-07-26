function [ T, output ] = computeWithLeakage(this, Pdyn, options)
  [ T, output ] = feval( ...
    options.get('algorithm', 'condensedEquation'), this, Pdyn, options);
end

function [ T, output ] = condensedEquation(this, Pdyn, options)
  iterationLimit   = options.get('iterationLimit', 20);
  temperatureLimit = options.get('temperatureLimit', Utils.toKelvin(1e3));
  tolerance        = options.get('tolerance', 0.5);

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

  switch options.get('version', 1)
  case 1 % Slower but more memory efficient
    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    X = zeros(nodeCount, stepCount);

    for i = 1:sampleCount
      v = repmat(V(:, i), [ 1, stepCount ]);

      Tlast = Tamb;

      for j = 1:iterationLimit
        P(:, :, i) = Pdyn + leakage.compute(v, T(:, :, i));

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
  case 2 % Faster but less memory efficient
    V = repmat(V, [ 1, 1, stepCount ]);
    Pdyn = permute(repmat(Pdyn, [ 1, 1, sampleCount ]), [ 1 3 2 ]);

    T = Tamb * ones(processorCount, sampleCount, stepCount);
    P = zeros(processorCount, sampleCount, stepCount);

    Q = zeros(nodeCount, sampleCount, stepCount);

    Tlast = Tamb;
    I = 1:sampleCount;

    for i = 1:iterationLimit
      P(:, I, :) = Pdyn(:, I, :) + ...
        leakage.compute(V(:, I, :), T(:, I, :));

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
      K = max(max(abs(Tcurrent - Tlast), [], 1), [], 3) < tolerance;
      iterationCount(I(K)) = i;

      M = J | K;
      I(M) = [];

      if isempty(I), break; end

      Tlast = Tcurrent;
      Tlast(:, M, :) = [];
    end

    T = permute(T, [ 1, 3, 2 ]);
    P = permute(P, [ 1, 3, 2 ]);
  otherwise
    assert(false);
  end

  I = isnan(iterationCount);
  T(:, :, I) = NaN;
  P(:, :, I) = NaN;

  output.P = P;
  output.iterationCount = iterationCount;
end

function [ T, output ] = blockCirculant(this, Pdyn, options)
  iterationLimit   = options.get('iterationLimit', 20);
  temperatureLimit = options.get('temperatureLimit', Utils.toKelvin(1e3));
  tolerance        = options.get('tolerance', 0.5);

  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  F = this.F;
  Tamb = this.Tamb;

  leakage = this.leakage;
  V = options.get('V', leakage.Vnom * ones(processorCount, 1));

  sampleCount = size(V, 2);

  A = cat(3, this.E, -eye(nodeCount));
  A = conj(fft(A, stepCount, 3));

  invA = cell(1, stepCount);
  for i = 1:stepCount
    invA{i} = inv(A(:, :, i));
  end

  switch options.get('version', 1)
  case 1 % Slower but more memory efficient
    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    X = zeros(nodeCount, stepCount);

    for i = 1:sampleCount
      v = repmat(V(:, i), [ 1, stepCount ]);

      Tlast = Tamb;

      for j = 1:iterationLimit
        P(:, :, i) = Pdyn + leakage.compute(v, T(:, :, i));

        B = fft(-F * P(:, :, i), stepCount, 2);

        for k = 1:stepCount
          X(:, k) = invA{k} * B(:, k);
        end

        Tcurrent = C * ifft(X, stepCount, 2) + Tamb;
        T(:, :, i) = Tcurrent;

        if max(max(Tcurrent)) > temperatureLimit
          %
          % Thermal runaway
          %
          j = NaN;
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
  case 2 % Faster but less memory efficient
    V = permute(repmat(V, [ 1, 1, stepCount ]), [ 1, 3, 2 ]);
    Pdyn = repmat(Pdyn, [ 1, 1, sampleCount ]);

    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    X = zeros(nodeCount, stepCount, sampleCount);
    Y = zeros(nodeCount, stepCount, sampleCount);

    Tlast = Tamb;
    I = 1:sampleCount;

    for i = 1:iterationLimit
      P(:, :, I) = Pdyn(:, :, I) + ...
        leakage.compute(V(:, :, I), T(:, :, I));

      for j = I
        Y(:, :, j) = -F * P(:, :, j);
      end

      B = fft(Y(:, :, I), stepCount, 2);

      for j = 1:stepCount
        X(:, j, I) = invA{j} * squeeze(B(:, j, :));
      end

      Y(:, :, I) = ifft(X(:, :, I), stepCount, 2);

      for j = I
        T(:, :, j) = C * Y(:, :, j) + Tamb;
      end

      Tcurrent = T(:, :, I);

      %
      % Thermal runaway
      %
      J = max(max(Tcurrent, [], 1), [], 2) > temperatureLimit;
      iterationCount(I(J)) = NaN;

      %
      % Successful convergence
      %
      K = max(max(abs(Tcurrent - Tlast), [], 1), [], 2) < tolerance;
      iterationCount(I(K)) = i;

      M = J | K;
      I(M) = [];

      if isempty(I), break; end

      Tlast = Tcurrent;
      Tlast(:, :, M) = [];
    end
  otherwise
    assert(false);
  end

  I = isnan(iterationCount);
  T(:, :, I) = NaN;
  P(:, :, I) = NaN;

  output.P = P;
  output.iterationCount = iterationCount;
end
