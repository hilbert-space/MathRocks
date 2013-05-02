function [ T, output ] = computeWithLeakage(this, Pdyn, varargin)
  options = Options(varargin{:});

  [ processorCount, stepCount ] = size(Pdyn);
  assert(processorCount == this.processorCount);

  E = this.E;
  D = this.D;
  BT = this.BT;
  Tamb = this.ambientTemperature;

  leakage = this.leakage;
  L = options.get('L', leakage.Lnom);

  if isscalar(L)
    L = L * ones(processorCount, 1);
  end

  T = zeros(processorCount, stepCount);
  Pleak = zeros(processorCount, stepCount);

  Pleak(:, 1) = leakage.evaluate(L, Tamb * ones(processorCount, 1));
  X = D * (Pdyn(:, 1) + Pleak(:, 1));
  T(:, 1) = BT * X + Tamb;

  for i = 2:stepCount
    Pleak(:, i) = leakage.evaluate(L, T(:, i - 1));
    X = E * X + D * (Pdyn(:, i) + Pleak(:, i));
    T(:, i) = BT * X + Tamb;
  end

  output.Pleak = Pleak;
end
