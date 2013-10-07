function assessTrigonometric
  %
  % Reference:
  %
  % J. Jakeman, A. Narayan, and D. Xiu. "Minimal Multi-element
  % Stochastic Collocation for Uncertainty Quantification of
  % Discontinuous Functions." Journal of Computational Physics,
  % 2013.
  %
  setup;

  assess(@(x) cube(2 * x - 1), ...
    'inputCount', 2, ...
    'maximalLevel', 30, ...
    'tolerance', 1e-3);
end

function y = cube(x)
  y = f1(x);
  I = all(abs(x) < 0.45, 2);
  y(I) = y(I) + 1;
end

function y = sphere(x)
  y = f1(x);
  I = sum(x.^2, 2) < 0.5^2;
  y(I) = y(I) + 1;
end

function y = triangle(x)
  y = f1(x) + 3;
  I = (sum(x, 2) > 1 / 4) | (diff(x, [], 2) > 1 / 4) | (x(:, 2) < -0.5);
  y(I) = y(I) - 3;
end

function y = plane(x)
  y = f2(x) + 0.5 * cos(pi * (sum(x, 2) + 0.3)) + 1;
  I = 3 * x(:, 1) + 2 * x(:, 2) - 0.01 > 0;
  y(I) = f1(x(I));
end

function y = f1(x)
  y = exp(-sum(x.^2, 2)) - sum(x.^3, 2);
end

function y = f2(x)
  y = 1 + f1(x) + (1 / (4 * size(x, 2))) * sum(x.^2, 2);
end
