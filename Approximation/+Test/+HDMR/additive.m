function additive
  setup;

  sampleCount = 100;
  inputDimension = 10;

  asgcOptions = Options( ...
    'inputDimension', inputDimension, ...
    'adaptivityControl', 'norm', ...
    'minLevel', 2, ...
    'maxLevel', 10, ...
    'tolerance', 1e-4);

  hdmrOptions = Options( ...
    'inputDimension', inputDimension, ...
    'maxOrder', 10, ...
    'interpolantOptions', asgcOptions, ...
    'orderTolerance', 1e-4, ...
    'dimensionTolerance', 1e-4);

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

    e1 = sqrt(sum((approximatedData - exactData).^2)) / sqrt(sum(exactData.^2));
    e2 = computeNRMSE(exactData, approximatedData);

    fprintf('Normalized L2:   %e\n', e1);
    fprintf('Normalized RMSE: %e\n', e2);
  end
end
