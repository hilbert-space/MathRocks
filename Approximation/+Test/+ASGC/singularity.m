function singularity
  setup;

  use('DataAnalysis');

  f = @problem3;

  tic;
  interpolant = ASGC(f, ...
    'inputCount', 2, ...
    'control', 'InfNormSurpluses', ...
    'minimalLevel', 2, ...
    'maximalLevel', 20, ...
    'tolerance', 1e-4, ...
    'verbose', true);
  fprintf('Interpolant construction: %.2f s\n', toc);

  display(interpolant);
  plot(interpolant);
  Plot.title('Sparse grid at level %d', interpolant.level);

  [ X, Y ] = meshgrid(linspace(0, 1), linspace(0, 1));
  [ M, N ] = size(X);

  XY = [ X(:), Y(:) ];

  Z0 = reshape(f(XY), M, N);

  tic;
  Z1 = interpolant.evaluate(XY);
  fprintf('Interpolant evaluation at %d points: %.2f s\n', size(XY, 1), toc);

  Z1 = reshape(Z1, M, N);

  fprintf('Infinity norm:   %e\n', norm(Z0 - Z1, Inf));
  fprintf('Normalized RMSE: %e\n', Error.computeNRMSE(Z0, Z1));
  fprintf('Normalized L2:   %e\n', Error.computeNL2(Z0, Z1));

  figure;

  subplot(1, 2, 1);
  meshc(X, Y, Z0);

  Plot.title('Original');

  subplot(1, 2, 2);
  meshc(X, Y, Z1);

  Plot.title('Interpolant at level %d', interpolant.level);
end

function y = problem1(x)
  y = 1 ./ (abs(0.3 - x(:, 1).^2 - x(:, 2).^2) + 0.1);
end

function y = problem2(x)
  y = exp(-x(:, 1).^2 + sign(x(:, 2)));
end

function y = problem3(x)
  y = sin(pi * x(:, 1)) .* sin(pi * x(:, 2));
  y(x(:, 1) > 0.5) = 0;
  y(x(:, 2) > 0.5) = 0;
end
