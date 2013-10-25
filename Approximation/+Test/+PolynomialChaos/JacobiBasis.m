function JacobiBasis
  setup;
  surrogate = PolynomialChaos.Jacobi( ...
    'inputCount', 1, 'outputCount', 1, 'order', 5, ...
    'alpha', 2, 'beta', 2, 'a', -1, 'b', 1);
  plot(surrogate);
  ylim([ -4, 4 ]);
end
