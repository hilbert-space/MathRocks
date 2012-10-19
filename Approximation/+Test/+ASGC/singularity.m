function singularity
  clear all;
  setup;

  f = @(x) 1 ./ (abs(0.3 - x(:, 1).^2 - x(:, 2).^2) + 0.1);
  % f = @(x) exp(-x(:, 1).^2 + sign(x(:, 2)));

  tic;
  interpolant = ASGC(f, ...
    'InputDimension', 2, ...
    'AdaptivityControl', 'InfNormSurpluses2', ...
    'MaximalLevel', 15, ...
    'Tolerance', 1e-2, ...
    'Verbose', true);
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

  figure;

  subplot(1, 2, 1);
  meshc(X, Y, Z0);

  Plot.title('Original');

  subplot(1, 2, 2);
  meshc(X, Y, Z1);

  Plot.title('Interpolant at level %d', interpolant.level);
end
