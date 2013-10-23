function HermiteBasis
  setup;
  surrogate = PolynomialChaos.Hermite( ...
    'inputCount', 1, 'outputCount', 1, 'order', 5);
  plot(surrogate);
end
