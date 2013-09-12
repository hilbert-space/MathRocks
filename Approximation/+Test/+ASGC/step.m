function step
  close all;
  setup;

  assess(@(u) problem(2 * u - 1), ...
    'inputCount', 1, ...
    'outputCount', 1);
end

function y = problem(x)
  y = ones(size(x));
  y(x > -1/2) = 0;
end
