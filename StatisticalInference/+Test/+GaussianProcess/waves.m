function waves
  clear all;
  close all;

  setup;

  a = -10;
  b = +10;

  function y = target(x)
    y = 4 * x.^2 + 20 * sin(2 * x) - 14 * x + 1;
  end

  function [ k, dk ] = kernel(s, t, l)
    n = sum((s - t).^2, 1) / 2;
    k = exp(-n / l^2);
    if nargout == 1, return; end
    dk = k .* l^(-3) .* n;
  end

  surrogate = Regression.GaussianProcess( ...
    'target', @(u) target(a + (b - a) * u), 'kernel', @kernel, ...
    'parameters', 0.2, 'lowerBound', 1e-4, 'upperBound', 10, ...
    'nodeCount', 10, 'verbose', true);

  x = linspace(a, b, 50)';

  y1 = target(x);
  [ y2, variance ] = surrogate.evaluate((x - a) / (b - a));

  deviation = sqrt(diag(variance));

  figure;
  line(x, y1, 'Color', Color.pick(1));
  line(x, y2, 'Color', Color.pick(2));
  line(x, y2 + deviation, 'Color', Color.pick(2), 'LineStyle', '--');
  line(x, y2 - deviation, 'Color', Color.pick(2), 'LineStyle', '--');
end
