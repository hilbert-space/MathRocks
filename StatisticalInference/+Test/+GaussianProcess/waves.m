function waves
  clear all;
  close all;

  setup;

  a = -10;
  b = +10;

  function y = target(x)
    y = 4 * x.^2 + 20 * sin(2 * x) - 14 * x + 1;
  end

  function k = kernel(t, s)
    k = exp(-sum((t - s).^2, 1) / 2 / 0.1);
  end

  surrogate = Regression.GaussianProcess( ...
    'target', @(u) target(a + (b - a) * u), 'kernel', @kernel, ...
    'nodeCount', 20, 'lowerBound', 1e-4, 'upperBound', 10, ...
    'verbose', true);

  x = linspace(a, b, 50)';

  y1 = target(x);
  y2 = surrogate.evaluate((x - a) / (b - a));

  figure;
  line(x, y1, 'Color', Color.pick(1));
  line(x, y2, 'Color', Color.pick(2));
end
