function [T, output] = computeWithoutLeakage(this, Pdyn, varargin)
  nodeCount = this.nodeCount;
  stepCount = size(Pdyn, 2);

  eval(this.algorithm);

  output = struct;

  return;

  function condensedEquation
    E = this.E;
    FP = this.F * Pdyn;

    W = FP(:, 1);

    for i = 2:stepCount
      W = E * W + FP(:, i);
    end

    X = zeros(nodeCount, stepCount);
    X(:, 1) = this.U * diag(1 ./ (1 - exp(this.samplingInterval * ...
      stepCount * this.L))) * this.V * W;

    for i = 2:stepCount
      X(:, i) = E * X(:, i - 1) + FP(:, i - 1);
    end

    T = this.C * X + this.D * Pdyn + this.ambientTemperature;
  end

  function blockCirculant
    A = cat(3, this.E, -eye(nodeCount));
    A = conj(fft(A, stepCount, 3));
    for i = 1:stepCount
      A(:, :, i) = inv(A(:, :, i));
    end

    X = zeros(nodeCount, stepCount);
    B = -fft(this.F * Pdyn, stepCount, 2);

    for i = 1:stepCount
      X(:, i) = A(:, :, i) * B(:, i);
    end

    T = this.C * ifft(X, stepCount, 2) + this.D * Pdyn + ...
      this.ambientTemperature;
  end
end
