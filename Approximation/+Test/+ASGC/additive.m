function additive
  setup;

  sampleCount = 1e3;
  inputDimension = 2;

  asgcOptions = Options( ...
    'inputDimension', inputDimension, ...
    'adaptivityControl', 'InfNormSurpluses2', ...
    'minLevel', 2, ...
    'maxLevel', 20, ...
    'tolerance', 1e-4, ...
    'verbose', true);

  f = @(u) sum(u.^2, 2);
  u = rand(sampleCount, inputDimension);

  tic;
  interpolant = ASGC(f, asgcOptions);
  fprintf('Interpolant construction: %.2f s\n', toc);

  display(interpolant);

  if inputDimension < 3
    plot(interpolant);
  end

  if inputDimension == 2
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
    Error.computeNormalizedL2(exactData, approximatedData);

  fprintf('Normalized L2: %e\n', normalizedError);

  fprintf('Analytical:\n');
  fprintf('  Expectation: %10.6f\n', inputDimension / 3);
  fprintf('  Variance:    %10.6f\n', inputDimension * 4 / 45);

  fprintf('Empirical:\n');
  fprintf('  Expectation: %10.6f\n', mean(approximatedData));
  fprintf('  Variance:    %10.6f\n', var(approximatedData));

  fprintf('Approximated:\n');
  fprintf('  Expectation: %10.6f\n', interpolant.expectation);
  fprintf('  Variance:    %10.6f\n', interpolant.variance);

  fprintf('Error:\n');
  fprintf('  Expectation: %10.6f\n', ...
    inputDimension / 3 - interpolant.expectation);
  fprintf('  Variance:    %10.6f\n', ...
    inputDimension * 4 / 45 - interpolant.variance);
end