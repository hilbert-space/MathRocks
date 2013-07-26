function [ compute, alpha, beta ] = linearizeLeakage(leakage, varargin)
  options = Options(varargin{:});

  VRange = options.get('VRange', leakage.VRange);
  TRange = options.get('TRange', leakage.TRange);
  pointCount = options.get('pointCount', 50);

  [ V, T ] = meshgrid( ...
    linspace(VRange(1), VRange(2), pointCount), ...
    linspace(TRange(1), TRange(2), pointCount));

  VT = [ V(:), T(:) ];
  I = leakage.compute(VT(:, 1), VT(:, 2));

  Vs = sym('V');
  Ts = sym('T');

  Cs = sym(zeros(1, 4));
  for i = 1:4
    Cs(i) = sym(sprintf('C%d', i));
  end

  alpha = Cs(1);
  beta = Cs(2) * exp(Cs(3) + Cs(4) * Vs);
  Fs = alpha * Ts + beta;

  [ compute, C ] = Utils.constructCustomFit(VT, I, Fs, [ Vs Ts ], Cs);

  alpha = C(1);
  beta = Utils.toFunction(subs(beta, Cs, C), Vs);
end
