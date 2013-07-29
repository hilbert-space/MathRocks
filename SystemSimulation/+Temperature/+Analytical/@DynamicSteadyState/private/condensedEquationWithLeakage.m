function [ T, output ] = condensedEquationWithLeakage(this, Pdyn, options)
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
