clear all;
setup;

f = @(x) 1 ./ (abs(0.3 - x(:, 1).^2 - x(:, 2).^2) + 0.1);
% f = @(x) exp(-x(:, 1).^2 + sign(x(:, 2)));

tic
interpolant = AdaptiveCollocation(f, ...
  'maxLevel', 20, 'tolerance', 1e-2);
toc

display(interpolant);
plot(interpolant);

[ X, Y ] = meshgrid(linspace(0, 1), linspace(0, 1));
[ M, N ] = size(X);

XY = [ X(:), Y(:) ];

Z0 = reshape(f(XY), M, N);

tic
Z1 = interpolant.evaluate(XY);
toc

Z1 = reshape(Z1, M, N);

figure;

subplot(1, 2, 1);
mesh(X, Y, Z0);

subplot(1, 2, 2);
mesh(X, Y, Z1);
