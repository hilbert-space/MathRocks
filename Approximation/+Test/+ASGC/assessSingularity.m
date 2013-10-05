function assessSingularity
  close all;
  setup;

  assess(@problem3, ...
    'inputCount', 2, ...
    'control', 'InfNormSurpluses', ...
    'minimalLevel', 2, ...
    'maximalLevel', 20, ...
    'tolerance', 1e-4);
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
