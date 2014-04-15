function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  [ processorCount, stepCount ] = size(Pdyn);
  if stepCount > 1, Pdyn = mean(Pdyn, 2); end

  R = this.R;
  Tamb = this.ambientTemperature;
  Tmax = this.maximalTemperature;
  errorMetric = this.errorMetric;
  errorThreshold = this.errorThreshold;
  iterationLimit = this.iterationLimit;

  leak = this.leakage.evaluate;
  parameterCount = this.leakage.parameterCount;

  [ parameters, sampleCount, Tindex ] = this.prepareParameters(varargin{:});

  Pindex = [ 1:(Tindex - 1), (Tindex + 1):parameterCount ];

  iterationCount = NaN(1, sampleCount);

  T = Tamb * ones(processorCount, sampleCount);
  P = zeros(processorCount, sampleCount);

  Tlast = Tamb;

  I = 1:sampleCount;
  leftCount = sampleCount;

  for i = 1:iterationLimit
    parameters{Tindex} = T(:, I);
    P(:, I) = repmat(Pdyn, [ 1, leftCount ]) + leak(parameters{:});

    Tcurrent = R * P(:, I) + Tamb;
    T(:, I) = Tcurrent;

    %
    % Thermal runaway
    %
    J = max(Tcurrent, [], 1) > Tmax;

    %
    % Successful convergence
    %
    K = Error.compute(errorMetric, Tcurrent, Tlast, 1) < errorThreshold;
    iterationCount(I(K)) = i;

    M = J | K;
    I(M) = [];

    leftCount = length(I);
    if leftCount == 0, break; end

    for j = Pindex
      parameters{j}(:, M) = [];
    end

    Tcurrent(:, M) = [];
    Tlast = Tcurrent;
  end

  I = isnan(iterationCount);
  T(:, I) = NaN;
  P(:, I) = NaN;

  output.P = P;
  output.iterationCount = iterationCount;

  runawayCount = sum(I);
  if runawayCount > 0
    warning([ 'Detected ', num2str(runawayCount), ' thermal runaways.' ]);
  end
end
