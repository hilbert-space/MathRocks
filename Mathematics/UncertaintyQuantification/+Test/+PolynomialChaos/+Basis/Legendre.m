function Legendre
  setup;
  surrogate = PolynomialChaos('basis', 'Legendre', ...
    'inputCount', 1, 'outputCount', 1, 'order', 5);
  plot(surrogate);
end
