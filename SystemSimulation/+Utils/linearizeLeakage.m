function [ compute, alpha, beta ] = linearizeLeakage(leakage, varargin)
  options = Options(varargin{:});

  VRange = options.get('VRange', leakage.VRange);
  TRange = options.get('TRange', leakage.TRange);
  pointCount = options.get('pointCount', 50);

  [ V, T ] = meshgrid( ...
    linspace(VRange(1), VRange(2), pointCount), ...
    linspace(TRange(1), TRange(2), pointCount));

  VT = [ V(:), T(:) ];
  P = leakage.compute(VT(:, 1), VT(:, 2));

  Vs = sym('V');
  Ts = sym('T');

  Cs = sym(zeros(1, 4));
  for i = 1:4
    Cs(i) = sym(sprintf('C%d', i));
  end

  alpha = Cs(1);
  beta = Cs(2) * exp(Cs(3) + Cs(4) * Vs);
  Fs = alpha * Ts + beta;

  [ compute, C, E, S ] = Utils.constructCustomFit(VT, P, Fs, [ Vs Ts ], Cs);

  %
  % The coefficients in C are for normalized V and T. So,
  % actual expression is
  %
  % P = C(1) * (T - E(2)) / S(2) + C(2) * exp(C(3) + C(4) * (V - E(1)) / S(1)).
  %
  alpha = C(1) / S(2);
  beta = subs(beta, Cs, C);
  beta = subs(beta, Vs, (Vs - E(1)) / S(1));
  beta = beta - C(1) * E(2) / S(2);
  beta = Utils.toFunction(beta, Vs);
end
