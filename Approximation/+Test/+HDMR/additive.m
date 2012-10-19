function additive
  setup;

  sampleCount = 100;
  inputDimension = 2;

  asgcOptions = Options( ...
    'inputDimension', inputDimension, ...
    'adaptivityControl', 'InfNormSurpluses2', ...
    'minLevel', 2, ...
    'maxLevel', 20, ...
    'tolerance', 1e-6, ...
    'verbose', true);

  hdmrOptions = Options( ...
    'inputDimension', inputDimension, ...
    'maxOrder', 10, ...
    'interpolantOptions', asgcOptions, ...
    'orderTolerance', 1e-4, ...
    'dimensionTolerance', 1e-4, ...
    'verbose', true);

  f = @(u) sum(u.^2, 2);
  u = rand(sampleCount, inputDimension);

  for order = [ 1, 2, 3 ];
    hdmrOptions.maxOrder = order;

    tic;
    interpolant = HDMR(f, hdmrOptions);
    fprintf('Interpolant construction: %.2f s\n', toc);

    display(interpolant);

    tic
    approximatedData = interpolant.evaluate(u);
    fprintf('Evaluation: %.2f s\n', toc);

    exactData = f(u);

    normalizedError = ...
      Error.computeNormalizedL2(exactData, approximatedData);

    fprintf('Normalized L2: %e\n', normalizedError);
  end
end
