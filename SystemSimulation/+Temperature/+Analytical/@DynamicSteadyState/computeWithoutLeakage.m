function T = computeWithoutLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});
  T = feval(options.get('algorithm', 'condensedEquation'), this, Pdyn);
end

function T = condensedEquation(this, Pdyn)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;

  Q = D * Pdyn;

  W = zeros(nodeCount, stepCount);
  W(:, 1) = Q(:, 1);

  for i = 2:stepCount
    W(:, i) = E * W(:, i - 1) + Q(:, i);
  end

  X = zeros(nodeCount, stepCount);
  X(:, 1) = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.UT * W(:, stepCount);

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
  end

  T = this.BT * X + this.ambientTemperature;
end

function T = blockCirculant(this, Pdyn)
  nodeCount = this.nodeCount;
  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;

  A = zeros(2, nodeCount, nodeCount);
  A(1, :, :) = E;
  A(2, :, :) = -eye(nodeCount);

  B = -D * Pdyn;

  A = conj(fft(A, stepCount, 1));
  B = fft(B, stepCount, 2);

  X = zeros(nodeCount, stepCount);

  for i = 1:stepCount
    X(:, i) = squeeze(A(i, :, :)) \ B(:, i);
  end

  T = this.BT * ifft(X, stepCount, 2) + this.ambientTemperature;
end
