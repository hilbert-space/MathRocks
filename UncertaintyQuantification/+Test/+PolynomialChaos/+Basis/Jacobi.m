function Jacobi
  setup;
  surrogate = PolynomialChaos('basis', 'Jacobi', ...
    'distribution', ProbabilityDistribution.Beta( ...
      'alpha', 2, 'beta', 2, 'a', 0, 'b', 1), ...
    'inputCount', 1, 'outputCount', 1, 'order', 5);
  plot(surrogate);
  ylim([ -3, 3 ]);
end
