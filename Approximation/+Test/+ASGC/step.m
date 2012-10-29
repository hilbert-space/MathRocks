function step
  approximation = ASGC( ...
    @(x) problem(2 * x - 1), ...
    'inputCount', 1, ...
    'outputCount', 1);

  display(approximation);
  plot(approximation);

  x = linspace(-1, 1).';

  y1 = problem(x);
  y2 = approximation.evaluate((x + 1) / 2);

  figure;

  line(x, y1, 'Color', Color.pick(1));
  line(x, y2, 'Color', Color.pick(2));

  ylim([ -0.5, 1.5 ]);
end

function y = problem(x)
  y = ones(size(x));
  y(x > -1/2) = 0;
end
