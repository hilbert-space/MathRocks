function additive
  setup;

  sampleCount = 100;
  inputDimension = 10;

  f = @(u) sum(u.^2, 2);
  u = rand(sampleCount, inputDimension);

  for order = [ 1, 2, 3 ];
    tic;
    interpolant = HDMR(f, ...
      'inputDimension', inputDimension, 'maxOrder', order, ...
      'dimensionTolerance', 1e-2, 'orderTolerance', 1e-2);
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
