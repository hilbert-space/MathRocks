function evaluateBasisMoments(i, j)
  validate(i, j);

  E = evaluateExpectation(i, j);
  R = evaluateSecondRawMoment(i, j);
  V = evaluateVariance(i, j);

  fprintf('Expectation:       %10.8f\n', E);
  fprintf('Second raw moment: %10.8f\n', R);
  fprintf('Variance:          %10.8f\n', V);
end
