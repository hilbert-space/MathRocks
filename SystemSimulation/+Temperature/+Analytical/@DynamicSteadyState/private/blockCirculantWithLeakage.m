function [ T, output ] = blockCirculantWithLeakage(this, Pdyn, options)
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
