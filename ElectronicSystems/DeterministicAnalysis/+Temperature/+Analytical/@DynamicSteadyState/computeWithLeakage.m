function [ T, output ] = computeWithLeakage(this, Pdyn, parameters, varargin)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);

  if nargin < 3, parameters = struct; end
  if nargin > 3
    options = Options(varargin{:});
  else
    options = Options;
  end

  C = this.C;
  D = this.D;
  E = this.E;
  F = this.F;
  Tamb = this.ambientTemperature;
  Tmax = this.maximalTemperature;

  algorithm = options.get('algorithm', this.algorithm);
  errorMetric = options.get('errorMetric', this.errorMetric);
  errorThreshold = options.get('errorThreshold', this.errorThreshold);
  iterationLimit = options.get('iterationLimit', this.iterationLimit);

  %
  % NOTE: If the model-order reduction is not performed, or
  % it is performed but based on truncation, D is zero.
  %
  hasD = nnz(D) > 0;

  leak = this.leakage.evaluate;

  [ parameters, sampleCount, temperatureIndex ] = ...
    this.prepareParameters(parameters);
  parameterCount = this.leakage.parameterCount;
  parameterIndex = [ 1:(temperatureIndex - 1), ...
    (temperatureIndex + 1):parameterCount ];

  iterationCount = NaN(1, sampleCount);

  eval(algorithm);

  output.P = P;
  output.iterationCount = iterationCount;

  if any(isnan(iterationCount))
    warning('Detected a thermal runaway.');
  end

  return;

  function condensedEquationSingle
    Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
      stepCount * this.L))) * this.V;

    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    X = zeros(nodeCount, stepCount);

    param = cell(1, parameterCount);
    for i = 1:sampleCount
      for j = parameterIndex
        param{j} = repmat(parameters{j}(:, i), [ 1, stepCount ]);
      end

      Tlast = Tamb;

      for j = 1:iterationLimit
        param{temperatureIndex} = T(:, :, i);

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

        if hasD
          Tcurrent = C * X + D * P(:, :, i) + Tamb;
        else
          Tcurrent = C * X + Tamb;
        end

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

  function condensedEquationMultiple
    Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
      stepCount * this.L))) * this.V;

    for i = parameterIndex
      parameters{i} = repmat(parameters{i}, [ 1, 1, stepCount ]);
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
      parameters{temperatureIndex} = T(:, I, :);
      P(:, I, :) = repmat(Pdyn, [ 1, leftCount, 1 ]) + leak(parameters{:});

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

      if hasD
        T(:, I, :) = reshape( ...
          C * reshape(X(:, I, :), nodeCount, []) + ...
          D * reshape(P(:, I, :), processorCount, []) + Tamb, ...
          [ processorCount, leftCount, stepCount ]);
      else
        T(:, I, :) = reshape( ...
          C * reshape(X(:, I, :), nodeCount, []) + Tamb, ...
          [ processorCount, leftCount, stepCount ]);
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

      for j = parameterIndex
        parameters{j}(:, M, :) = [];
      end

      Tcurrent(M, :) = [];
      Tlast = Tcurrent;
    end

    T = permute(T, [ 1, 3, 2 ]);
    P = permute(P, [ 1, 3, 2 ]);
  end

  function condensedEquationMultipleSimplified
    Z = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
      stepCount * this.L))) * this.V;

    assert(temperatureIndex == 1);

    parameters = parameters(2:end);

    for i = 1:(parameterCount - 1)
      parameters{i} = repmat(parameters{i}, [ 1, 1, stepCount ]);
      parameters{i} = reshape(parameters{i}, processorCount, []);
    end

    Pdyn = repmat(Pdyn, [ 1, 1, sampleCount ]);
    Pdyn = permute(Pdyn, [ 1, 3, 2 ]);
    Pdyn = reshape(Pdyn, processorCount, sampleCount * stepCount);

    %
    % NOTE: There is no error control; the number of iterations is fixed;
    % and the initial temperature is assumed to be given.
    %
    assert(isinf(errorThreshold));
    iterationCount(:) = iterationLimit;

    T = reshape(repmat(permute(options.T, [ 1, 3, 2 ]), ...
      [ 1, sampleCount, 1 ]), processorCount, sampleCount * stepCount);
    P = zeros(processorCount, sampleCount * stepCount);

    FP = zeros(nodeCount, sampleCount, stepCount);
    X = zeros(nodeCount, sampleCount, stepCount);

    for i = 1:iterationLimit
      P(:) = Pdyn + leak(T, parameters{:});

      FP(:) = reshape(F * P, [ nodeCount, sampleCount, stepCount ]);

      W = FP(:, :, 1);
      for j = 2:stepCount
        W = E * W + FP(:, :, j);
      end

      X(:, :, 1) = Z * W;
      for j = 2:stepCount
        X(:, :, j) = E * X(:, :, j - 1) + FP(:, :, j - 1);
      end

      T(:) = C * reshape(X, nodeCount, sampleCount * stepCount) + D * P + Tamb;
    end

    T = reshape(T, [ processorCount, sampleCount, stepCount ]);
    T = permute(T, [ 1, 3, 2 ]);

    P = reshape(P, [ processorCount, sampleCount, stepCount ]);
    P = permute(P, [ 1, 3, 2 ]);
  end

  function blockCirculantSingle
    A = cat(3, E, -eye(nodeCount));
    A = conj(fft(A, stepCount, 3));
    for i = 1:stepCount
      A(:, :, i) = inv(A(:, :, i));
    end

    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    X = zeros(nodeCount, stepCount);

    param = cell(1, parameterCount);
    for i = 1:sampleCount
      for j = parameterIndex
        param{j} = repmat(parameters{j}(:, i), [ 1, stepCount ]);
      end

      Tlast = Tamb;

      for j = 1:iterationLimit
        param{temperatureIndex} = T(:, :, i);

        P(:, :, i) = Pdyn + leak(param{:});

        B = -fft(F * P(:, :, i), stepCount, 2);

        for k = 1:stepCount
          X(:, k) = A(:, :, k) * B(:, k);
        end

        if hasD
          Tcurrent = C * ifft(X, stepCount, 2) + D * P(:, :, i) + Tamb;
        else
          Tcurrent = C * ifft(X, stepCount, 2) + Tamb;
        end

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

  function blockCirculantMultiple
    A = cat(3, E, -eye(nodeCount));
    A = conj(fft(A, stepCount, 3));
    for i = 1:stepCount
      A(:, :, i) = inv(A(:, :, i));
    end

    for i = parameterIndex
      parameters{i} = repmat(parameters{i}, [ 1, 1, stepCount ]);
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
      parameters{temperatureIndex} = T(:, I, :);
      P(:, I, :) = repmat(Pdyn, [ 1, leftCount, 1 ]) + leak(parameters{:});

      X(:, I, :) = reshape( ...
        F * reshape(P(:, I, :), processorCount, []), ...
        [ nodeCount, leftCount, stepCount ]);

      B(:, I, :) = -fft(X(:, I, :), stepCount, 3);

      for j = 1:stepCount
        X(:, I, j) = A(:, :, j) * B(:, I, j);
      end

      X(:, I, :) = ifft(X(:, I, :), stepCount, 3);

      if hasD
        T(:, I, :) = reshape( ...
          C * reshape(X(:, I, :), nodeCount, []) + ...
          D * reshape(P(:, I, :), processorCount, []) + Tamb, ...
          [ processorCount, leftCount, stepCount ]);
      else
        T(:, I, :) = reshape( ...
          C * reshape(X(:, I, :), nodeCount, []) + Tamb, ...
          [ processorCount, leftCount, stepCount ]);
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

      for j = parameterIndex
        parameters{j}(:, M, :) = [];
      end

      Tcurrent(M, :) = [];
      Tlast = Tcurrent;
    end

    T = permute(T, [ 1, 3, 2 ]);
    P = permute(P, [ 1, 3, 2 ]);
  end

  function blockCirculantMeteor
    %
    % We are to solve the following system of linear equations:
    %
    %   A * X = B
    %
    % where
    %
    %       |   E  -I ... ...   0 |
    %       |   0   E  -I ...   0 |
    %   A = | ... ... ... ... ... | and
    %       |   0   0 ...   E  -I |
    %       |  -I   0   0 ...   E |
    %
    %       | -F * P1 |
    %   B = |   ...   |.
    %       | -F * Pn |
    %
    % The solution is
    %
    %   X = A^(-1) * B = (redefine A) = A * B.
    %
    % First, we compute the inverse of A, which we shall store
    % in the place of A.
    %
    A = conj(fft(cat(3, E, -eye(nodeCount)), stepCount, 3));
    for i = 1:stepCount
      A(:, :, i) = inv(A(:, :, i));
    end
    A = ifft(A, stepCount, 3);
    %
    % At this point, A is the transpose of what we actually want.
    % The following two lines perform a matrix transpose.
    %
    A = permute(A, [ 2, 1, 3 ]);
    A = reshape(A(:, :, [ 1, end:-1:2 ]), nodeCount, nodeCount * stepCount);

    for i = parameterIndex
      parameters{i} = repmat(permute(parameters{i}, ...
        [ 1, 3, 2 ]), [ 1, stepCount, 1 ]);
    end

    T = Tamb * ones(processorCount, stepCount, sampleCount);
    P = zeros(processorCount, stepCount, sampleCount);

    B = zeros(nodeCount * stepCount, sampleCount);
    X = zeros(nodeCount, stepCount, sampleCount);

    Tlast = Tamb;

    I = 1:sampleCount;
    leftCount = sampleCount;

    for i = 1:iterationLimit
      parameters{temperatureIndex} = T(:, :, I);
      P(:, :, I) = repmat(Pdyn, [ 1, 1, leftCount ]) + leak(parameters{:});

      B(:, I) = reshape( ...
        -F * reshape(P(:, :, I), processorCount, []), ...
        [ nodeCount * stepCount, leftCount ]);

      for j = 1:stepCount
        X(:, j, I) = A * B(:, I);
        B(:, I) = [ B((nodeCount + 1):end, I); B(1:nodeCount, I) ];
      end

      if hasD
        T(:, :, I) = reshape( ...
          C * reshape(X(:, :, I), nodeCount, []) + ...
          D * reshape(P(:, :, I), processorCount, []) + Tamb, ...
          [ processorCount, stepCount, leftCount ]);
      else
        T(:, :, I) = reshape( ...
          C * reshape(X(:, :, I), nodeCount, []) + Tamb, ...
          [ processorCount, stepCount, leftCount ]);
      end

      Tcurrent = reshape(shiftdim(T(:, :, I), 2), leftCount, []);

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

      for j = parameterIndex
        parameters{j}(:, :, M) = [];
      end

      Tcurrent(M, :) = [];
      Tlast = Tcurrent;
    end
  end
end
