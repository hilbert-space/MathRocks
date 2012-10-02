% clear all;
setup;

f = @(x) 1 ./ (abs(0.3 - x(:, 1).^2 - x(:, 2).^2) + 0.1);

interpolant = AdaptiveCollocation(f, ...
  'maxLevel', 16);

display(interpolant);
plot(interpolant);

return;

figure;
interpolant.plot();
title('Sparse grid');

[ X, Y ] = meshgrid(linspace(0, 1), linspace(0, 1));
[ M, N ] = size(X);

XY = [ X(:), Y(:) ];

Z0 = reshape(f(XY), M, N);
Z1 = reshape(interpolant.compute(XY), M, N);

figure;

subplot(1, 2, 1);
mesh(X, Y, Z0);

subplot(1, 2, 2);
mesh(X, Y, Z1);
