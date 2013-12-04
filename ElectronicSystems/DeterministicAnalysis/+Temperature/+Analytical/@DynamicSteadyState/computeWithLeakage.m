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

  Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.V;

  leakage = this.leakage;
  leak = leakage.evaluate;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  param = cell(1, leakage.parameterCount);
  Pindex = setdiff(1:leakage.parameterCount, Tindex);

  iterationCount = NaN(1, sampleCount);

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
  case 2 % Faster but less memory efficient
    for i = Pindex
      parameters{i} = repmat( ...
        parameters{i}, [ 1, 1, stepCount ]);
    end

    Pdyn = permute(repmat(Pdyn, [ 1, 1, sampleCount ]), [ 1 3 2 ]);

    T = Tamb * ones(processorCount, sampleCount, stepCount);
    P = zeros(processorCount, sampleCount, stepCount);

    FP = zeros(nodeCount, sampleCount, stepCount);

    Tlast = Tamb * ones(sampleCount, processorCount * stepCount);

    I = 1:sampleCount;
    leftCount = sampleCount;

    for i = 1:iterationLimit
      for j = Pindex
        param{j} = parameters{j}(:, I, :);
      end
      param{Tindex} = T(:, I, :);

      P(:, I, :) = Pdyn(:, I, :) + leak(param{:});

      FP(:, I, 1) = F * P(:, I, 1);
      W = FP(:, I, 1);
      for j = 2:stepCount
        FP(:, I, j) = F * P(:, I, j);
        W = E * W + FP(:, I, j);
      end

      X = Z * W;
      T(:, I, 1) = C * X + D * P(:, I, 1) + Tamb;
      for j = 2:stepCount
        X = E * X + FP(:, I, j - 1);
        T(:, I, j) = C * X + D * P(:, I, j) + Tamb;
      end

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

      Tlast = Tcurrent;
      Tlast(M, :) = [];
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

  runawayCount = sum(I);
  if runawayCount > 0
    warning([ 'Detected ', num2str(runawayCount), ' thermal runaways.' ]);
  end
end
