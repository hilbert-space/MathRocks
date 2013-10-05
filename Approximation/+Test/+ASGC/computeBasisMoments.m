function computeBasisMoments(i, j)
  validate(i, j);

  E = computeExpectation(i, j);
  R = computeSecondRawMoment(i, j);
  V = computeVariance(i, j);

  fprintf('Expectation:       %10.8f\n', E);
  fprintf('Second raw moment: %10.8f\n', R);
  fprintf('Variance:          %10.8f\n', V);
end
