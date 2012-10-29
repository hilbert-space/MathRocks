function additive
  setup;
  rng(0);

  sampleCount = 1e3;
  inputCount = 10;

  asgcOptions = Options( ...
    'inputCount', inputCount, ...
    'adaptivityControl', 'InfNorm', ...
    'tolerance', 1e-2, ...
    'maximalLevel', 20, ...
    'verbose', true);

  hdmrOptions = Options( ...
    'inputCount', inputCount, ...
    'interpolantOptions', asgcOptions, ...
    'orderTolerance', 1e-2, ...
    'dimensionTolerance', 1e-2, ...
    'maximalOrder', 10, ...
    'verbose', true);

  f = @(u) sum(u.^2, 2);
  u = rand(sampleCount, inputCount);

  tic;
  interpolant = HDMR(f, hdmrOptions);
  fprintf('Interpolant construction: %.2f s\n', toc);

  display(interpolant);

  tic
  approximatedData = interpolant.evaluate(u);
  fprintf('Evaluation: %.2f s\n', toc);

  exactData = f(u);

  normalizedError = ...
    Error.computeNL2(exactData, approximatedData);

  fprintf('Normalized L2: %e\n', normalizedError);

  fprintf('Analytical:\n');
  fprintf('  Expectation: %12.8f\n', inputCount / 3);
  fprintf('  Variance:    %12.8f\n', inputCount * 4 / 45);

  fprintf('Empirical:\n');
  fprintf('  Expectation: %12.8f\n', mean(approximatedData));
  fprintf('  Variance:    %12.8f\n', var(approximatedData));

  fprintf('Approximated:\n');
  fprintf('  Expectation: %12.8f\n', interpolant.expectation);
  fprintf('  Variance:    %12.8f\n', interpolant.variance);

  fprintf('Error:\n');
  fprintf('  Expectation: %12.8f\n', ...
    inputCount / 3 - interpolant.expectation);
  fprintf('  Variance:    %12.8f\n', ...
    inputCount * 4 / 45 - interpolant.variance);
end
