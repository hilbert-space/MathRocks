function [ fitresult, gof, expectation, deviation ] = ...
  performPolynomialFit(L, T, I, order)

  [ X, Y, Z ] = prepareSurfaceData(L, T, I);
  X = [ X, Y ];
  Y = Z;

  type = fittype(sprintf('poly%d%d', order(1), order(2)));

  count = order(1) * order(2) + 1;

  options = fitoptions(type);
  options.Normalize = 'off';
  options.Lower = -Inf(1, count);
  options.Upper =  Inf(1, count);

  [ X, expectation, deviation ] = curvefit.normalize(X);
  [ fitresult, gof ] = fit(X, Y, type, options);
end
