function LegendreBasis
  setup;
  surrogate = PolynomialChaos.Legendre( ...
    'inputCount', 1, 'outputCount', 1, 'order', 5);
  plot(surrogate);
end
