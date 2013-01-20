function waves
  clear all;
  close all;

  setup;

  a = -10;
  b = +10;

  function y = target(x)
    y = 4 * x.^2 + 20 * sin(2 * x) - 14 * x + 1;
  end

  function [ K, dK ] = kernel(x, y, params)
    s = params(1); % Standard deviation
    l = params(2); % Length scale

    n = sum((x - y).^2, 1);
    K = s^2 * exp(-n / 2 / l^2);

    if nargout == 1, return; end % Need derivatives?

    dK = [ K .* l^(-3) .* n; K * 2 * s ];
  end

  surrogate = Regression.GaussianProcess( ...
    'target', @(u) target(a + (b - a) * u), 'kernel', @kernel, ...
    'parameters', [  1.00,  0.20 ], ...
    'lowerBound', [  0.01,  0.01 ], ...
    'upperBound', [ 10.00, 10.00 ], ...
    'startCount', 10, ...
    'nodeCount', 20, 'verbose', true);

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
