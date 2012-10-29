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

  f = @(u) sum(u.^2, 2);
  u = rand(sampleCount, inputCount);

  tic;
  interpolant = ASGC(f, asgcOptions);
  fprintf('Interpolant construction: %.2f s\n', toc);

  display(interpolant);

  if inputCount < 3
    plot(interpolant);
  end

  if inputCount == 2
    x = 0:0.1:1;
    y = 0:0.1:1;
    [ X, Y ] = meshgrid(x, y);
    Z = zeros(size(X));

    figure;

    Z(:) = f([ X(:) Y(:) ]);
    subplot(1, 2, 1);
    mesh(X, Y, Z);
    Plot.title('Exact');

    Z(:) = interpolant.evaluate([ X(:) Y(:) ]);
    subplot(1, 2, 2);
    mesh(X, Y, Z);
    Plot.title('Approximated');
  end

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
