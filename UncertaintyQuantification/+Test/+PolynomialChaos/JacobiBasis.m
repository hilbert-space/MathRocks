function JacobiBasis
  setup;
  surrogate = PolynomialChaos.Jacobi( ...
    'inputCount', 1, 'outputCount', 1, 'order', 5);
  plot(surrogate);
  ylim([ -4, 4 ]);
end
