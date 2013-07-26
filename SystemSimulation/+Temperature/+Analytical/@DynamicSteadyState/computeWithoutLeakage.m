function T = computeWithoutLeakage(this, Pdyn, options)
  T = feval(options.get('algorithm', 'condensedEquation'), this, Pdyn);
end

function T = condensedEquation(this, Pdyn)
  nodeCount = this.nodeCount;
  stepCount = size(Pdyn, 2);

  E = this.E;
  F = this.F;

  Q = F * Pdyn;
  W = Q(:, 1);

  for i = 2:stepCount
    W = E * W + Q(:, i);
  end

  X = zeros(nodeCount, stepCount);
  X(:, 1) = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
    stepCount * this.L))) * this.U' * W;

  for i = 2:stepCount
    X(:, i) = E * X(:, i - 1) + Q(:, i - 1);
  end

  T = this.C * X + this.Tamb;
end

function T = blockCirculant(this, Pdyn)
  nodeCount = this.nodeCount;
  stepCount = size(Pdyn, 2);

  A = cat(3, this.E, -eye(nodeCount));
  A = conj(fft(A, stepCount, 3));

  B = fft(-this.F * Pdyn, stepCount, 2);

  X = zeros(nodeCount, stepCount);

  for i = 1:stepCount
    X(:, i) = A(:, :, i) \ B(:, i);
  end

  T = this.C * ifft(X, stepCount, 2) + this.Tamb;
end
