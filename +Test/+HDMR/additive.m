function additive
  setup;
  rng(0);

  sampleCount = 1e3;
  inputCount = 10;

  asgcOptions = Options( ...
    'inputCount', inputCount, ...
    'absoluteTolerance', 1e-4, ...
    'relativeTolerance', 1e-2, ...
    'maximalLevel', 20, ...
    'verbose', false);

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
  exactData = f(u);
  fprintf('Sampling: %.2f s\n', toc);

  tic;
  interpolant = HDMR(f, hdmrOptions);
  fprintf('Interpolation: %.2f s\n', toc);

  display(interpolant);

  tic;
  approximatedData = interpolant.evaluate(u);
  fprintf('Evaluation: %.2f s\n', toc);

  normalizedError = Error.computeNL2(exactData, approximatedData);

  fprintf('Data:\n');
  fprintf('  L2: %e\n', normalizedError);

  fprintf('Expectation:\n');
  fprintf('  Exact:      %12.8f\n', inputCount / 3);
  fprintf('  Empirical:  %12.8f\n', mean(approximatedData));
  fprintf('  Analytical: %12.8f\n', interpolant.expectation);
end
