function hat
  close all;
  setup;

  [ asgcOutput, ~, asgc ] = assess( ...
    @(x) problem(5 * x - 1), ...
    'inputCount', 1, ...
    'outputCount', 1);

  x = linspace(-1, 4).';

  y1 = problem(x);
  y2 = asgc.evaluate(asgcOutput, (x + 1) / 5);

  figure;

  line(x, y1, 'Color', Color.pick(1));
  line(x, y2, 'Color', Color.pick(2));
end

function y = problem(x)
  y = zeros(size(x));
  I = logical((0 <= x) .* (x < 1));
  y(I) = (1/2) * x(I).^2;
  I = logical((1 <= x) .* (x < 2));
  y(I) = (1/2) * (-2 * x(I).^2 + 6 * x(I) - 3);
  I = logical((2 <= x) .* (x < 3));
  y(I) = (1/2) * (3 - x(I)).^2;
end
