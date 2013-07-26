function T = blockCirculantWithoutLeakage(this, Pdyn, options)
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
