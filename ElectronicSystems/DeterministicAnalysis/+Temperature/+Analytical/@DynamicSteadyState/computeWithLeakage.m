function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  C = this.C;
  D = this.D;
  E = this.E;
  F = this.F;
  Tamb = this.ambientTemperature;
  Tmax = this.maximalTemperature;
  errorMetric = this.errorMetric;
  errorThreshold = this.errorThreshold;
  iterationLimit = this.iterationLimit;

  leak = this.leakage.evaluate;
  parameterCount = this.leakage.parameterCount;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  param = cell(1, parameterCount);
  Pindex = [ 1:(Tindex - 1), (Tindex + 1):parameterCount ];

  iterationCount = NaN(1, sampleCount);

  eval(this.solverName);

  I = isnan(iterationCount);
  T(:, :, I) = NaN;
  P(:, :, I) = NaN;

  output.P = P;
  output.iterationCount = iterationCount;

  runawayCount = sum(I);
  if runawayCount > 0
    warning([ 'Detected ', num2str(runawayCount), ' thermal runaways.' ]);
  end

  return;

  function condensedEquationMemory
    Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
      stepCount * this.L))) * this.V;

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

        FP = F * P(:, :, i);
        W = FP(:, 1);
        for k = 2:stepCount
          W = E * W + FP(:, k);
        end

        X(:, 1) = Z * W;
        for k = 2:stepCount
          X(:, k) = E * X(:, k - 1) + FP(:, k - 1);
        end

        Tcurrent = C * X + D * P(:, :, i) + Tamb;
        T(:, :, i) = Tcurrent;

        if max(Tcurrent(:)) > Tmax
          %
          % Thermal runaway
          %
          break;
        end

        if Error.compute(errorMetric, Tcurrent, Tlast) < errorThreshold
          %
          % Successful convergence
          %
          iterationCount(i) = j;
          break;
        end

        Tlast = Tcurrent;
      end
    end
  end

  function condensedEquationSpeed
    Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
      stepCount * this.L))) * this.V;

    for i = Pindex
      parameters{i} = repmat( ...
        parameters{i}, [ 1, 1, stepCount ]);
    end

    Pdyn = reshape(Pdyn, [ processorCount, 1, stepCount ]);

    T = Tamb * ones(processorCount, sampleCount, stepCount);
    P = zeros(processorCount, sampleCount, stepCount);

    FP = zeros(nodeCount, sampleCount, stepCount);
    X = zeros(nodeCount, sampleCount, stepCount);

    Tlast = Tamb;

    I = 1:sampleCount;
    leftCount = sampleCount;

    for i = 1:iterationLimit
      for j = Pindex
        param{j} = parameters{j}(:, I, :);
      end
      param{Tindex} = T(:, I, :);

      P(:, I, :) = repmat(Pdyn, [ 1, leftCount, 1 ]) + leak(param{:});

      FP(:, I, :) = reshape( ...
        F * reshape(P(:, I, :), processorCount, []), ...
        [ nodeCount, leftCount, stepCount ]);

      W = FP(:, I, 1);
      for j = 2:stepCount
        W = E * W + FP(:, I, j);
      end

      X(:, I, 1) = Z * W;
      for j = 2:stepCount
        X(:, I, j) = E * X(:, I, j - 1) + FP(:, I, j - 1);
      end

      T(:, I, :) = reshape( ...
        C * reshape(X(:, I, :), nodeCount, []) + ...
        D * reshape(P(:, I, :), processorCount, []) + Tamb, ...
        [ processorCount, leftCount, stepCount ]);

      Tcurrent = reshape(shiftdim(T(:, I, :), 1), leftCount, []);

      %
      % Thermal runaway
      %
      J = max(Tcurrent, [], 2) > Tmax;

      %
      % Successful convergence
      %
      K = Error.compute(errorMetric, Tcurrent, Tlast, 2) < errorThreshold;
      iterationCount(I(K)) = i;

      M = J | K;
      I(M) = [];

      leftCount = length(I);
      if leftCount == 0, break; end

      Tcurrent(M, :) = [];
      Tlast = Tcurrent;
    end

    T = permute(T, [ 1, 3, 2 ]);
    P = permute(P, [ 1, 3, 2 ]);
  end

  function blockCirculantMemory
    A = cat(3, E, -eye(nodeCount));
    A = conj(fft(A, stepCount, 3));

    invA = cell(1, stepCount);
    for i = 1:stepCount
      invA{i} = inv(A(:, :, i));
    end

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

        B = -fft(F * P(:, :, i), stepCount, 2);

        for k = 1:stepCount
          X(:, k) = invA{k} * B(:, k);
        end

        Tcurrent = C * ifft(X, stepCount, 2) + D * P(:, :, i) + Tamb;
        T(:, :, i) = Tcurrent;

        if max(Tcurrent(:)) > Tmax
          %
          % Thermal runaway
          %
          break;
        end

        if Error.compute(errorMetric, Tcurrent, Tlast) < errorThreshold
          %
          % Successful convergence
          %
          iterationCount(i) = j;
          break;
        end

        Tlast = Tcurrent;
      end
    end
  end

  function blockCirculantSpeed
    A = cat(3, E, -eye(nodeCount));
    A = conj(fft(A, stepCount, 3));

    invA = cell(1, stepCount);
    for i = 1:stepCount
      invA{i} = inv(A(:, :, i));
    end

    for i = Pindex
      parameters{i} = repmat( ...
        parameters{i}, [ 1, 1, stepCount ]);
    end

    Pdyn = reshape(Pdyn, [ processorCount, 1, stepCount ]);

    T = Tamb * ones(processorCount, sampleCount, stepCount);
    P = zeros(processorCount, sampleCount, stepCount);

    B = zeros(nodeCount, sampleCount, stepCount);
    X = zeros(nodeCount, sampleCount, stepCount);

    Tlast = Tamb;

    I = 1:sampleCount;
    leftCount = sampleCount;

    for i = 1:iterationLimit
      for j = Pindex
        param{j} = parameters{j}(:, I, :);
      end
      param{Tindex} = T(:, I, :);

      P(:, I, :) = repmat(Pdyn, [ 1, leftCount, 1 ]) + leak(param{:});

      X(:, I, :) = reshape( ...
        F * reshape(P(:, I, :), processorCount, []), ...
        [ nodeCount, leftCount, stepCount ]);

      B(:, I, :) = -fft(X(:, I, :), stepCount, 3);

      for j = 1:stepCount
        X(:, I, j) = invA{j} * B(:, I, j);
      end

      X(:, I, :) = ifft(X(:, I, :), stepCount, 3);

      T(:, I, :) = reshape( ...
        C * reshape(X(:, I, :), nodeCount, []) + ...
        D * reshape(P(:, I, :), processorCount, []) + Tamb, ...
        [ processorCount, leftCount, stepCount ]);

      Tcurrent = reshape(shiftdim(T(:, I, :), 1), leftCount, []);

      %
      % Thermal runaway
      %
      J = max(Tcurrent, [], 2) > Tmax;

      %
      % Successful convergence
      %
      K = Error.compute(errorMetric, Tcurrent, Tlast, 2) < errorThreshold;
      iterationCount(I(K)) = i;

      M = J | K;
      I(M) = [];

      leftCount = length(I);
      if leftCount == 0, break; end

      Tcurrent(M, :) = [];
      Tlast = Tcurrent;
    end

    T = permute(T, [ 1, 3, 2 ]);
    P = permute(P, [ 1, 3, 2 ]);
  end
end
